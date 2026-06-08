package controllers

import (
	"net/http"
	"regexp"
	"strings"

	"app/database"
	"app/models"

	"github.com/labstack/echo-contrib/v5/session"
	"github.com/labstack/echo/v5"
	"golang.org/x/crypto/bcrypt"
)

const sessionName = "session"
const sessionUserIDKey = "userID"

var emailRegex = regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)

type registerRequest struct {
	Name            string `json:"name"`
	Email           string `json:"email"`
	Password        string `json:"password"`
	ConfirmPassword string `json:"confirm_password"`
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type accountUpdateRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type userResponse struct {
	ID    uint   `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

func toUserResponse(user models.User) userResponse {
	return userResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
	}
}

func getUserIDFromSession(c *echo.Context) (uint, error) {
	sess, err := session.Get(sessionName, c)
	if err != nil {
		return 0, echo.ErrUnauthorized
	}

	userIDValue := sess.Values[sessionUserIDKey]
	if userIDValue == nil {
		return 0, echo.ErrUnauthorized
	}

	userID, ok := userIDValue.(uint)
	if !ok {
		return 0, echo.ErrUnauthorized
	}

	return userID, nil
}

func Register(c *echo.Context) error {
	var req registerRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request body"})
	}

	req.Name = strings.TrimSpace(req.Name)
	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if req.Name == "" || req.Email == "" || req.Password == "" || req.ConfirmPassword == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "all fields are required"})
	}

	if !emailRegex.MatchString(req.Email) {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid email format"})
	}

	if len(req.Password) < 8 {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "password must be at least 8 characters"})
	}

	if req.Password != req.ConfirmPassword {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "passwords do not match"})
	}

	var existing models.User
	if err := database.DB.Where("email = ?", req.Email).First(&existing).Error; err == nil {
		return c.JSON(http.StatusConflict, map[string]string{"error": "email already registered"})
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to hash password"})
	}

	user := models.User{
		Name:         req.Name,
		Email:        req.Email,
		PasswordHash: string(passwordHash),
	}

	if err := database.DB.Create(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to create user"})
	}

	return c.JSON(http.StatusCreated, toUserResponse(user))
}

func Login(c *echo.Context) error {
	var req loginRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request body"})
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))
	if req.Email == "" || req.Password == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "email and password are required"})
	}

	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
	}

	sess, err := session.Get(sessionName, c)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to create session"})
	}

	sess.Values[sessionUserIDKey] = user.ID
	if err := sess.Save(c.Request(), c.Response()); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to save session"})
	}

	return c.JSON(http.StatusOK, toUserResponse(user))
}

func Logout(c *echo.Context) error {
	sess, err := session.Get(sessionName, c)
	if err != nil {
		return c.NoContent(http.StatusOK)
	}

	sess.Options.MaxAge = -1
	if err := sess.Save(c.Request(), c.Response()); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to clear session"})
	}

	return c.NoContent(http.StatusOK)
}

func GetMe(c *echo.Context) error {
	userID, err := getUserIDFromSession(c)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
	}

	return c.JSON(http.StatusOK, toUserResponse(user))
}

func UpdateAccount(c *echo.Context) error {
	userID, err := getUserIDFromSession(c)
	if err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
	}

	var req accountUpdateRequest
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request body"})
	}

	req.Name = strings.TrimSpace(req.Name)
	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	if req.Name == "" || req.Email == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "name and email are required"})
	}

	if !emailRegex.MatchString(req.Email) {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid email format"})
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
	}

	var existing models.User
	if err := database.DB.Where("email = ? AND id <> ?", req.Email, userID).First(&existing).Error; err == nil {
		return c.JSON(http.StatusConflict, map[string]string{"error": "email already in use"})
	}

	user.Name = req.Name
	user.Email = req.Email

	if err := database.DB.Save(&user).Error; err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "failed to update account"})
	}

	return c.JSON(http.StatusOK, toUserResponse(user))
}
