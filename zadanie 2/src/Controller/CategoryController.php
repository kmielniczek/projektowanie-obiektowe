<?php

namespace App\Controller;

use App\Dto\CategoryInput;
use App\Dto\CategoryUpdateInput;
use App\Entity\Category;
use App\Repository\CategoryRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\ObjectMapper\ObjectMapperInterface;
use Symfony\Component\Routing\Attribute\Route;

#[Route('api/categories', name: 'categories_', format: 'json')]
final class CategoryController extends AbstractController
{
    #[Route('', name: 'list', methods: ['GET'])]
    public function index(CategoryRepository $categoryRepository): JsonResponse
    {
        $categories = $categoryRepository->findAll();

        return $this->json($categories, context: ['groups' => 'api']);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(
        #[MapRequestPayload] CategoryInput $categoryInput,
        ObjectMapperInterface $objectMapper,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $category = $objectMapper->map($categoryInput);
        $entityManager->persist($category);
        $entityManager->flush();

        return $this->json($category, 201, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Category $category): JsonResponse
    {
        return $this->json($category, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT'])]
    public function update(
        #[MapRequestPayload] CategoryUpdateInput $categoryInput,
        Category $category,
        ObjectMapperInterface $objectMapper,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $objectMapper->map($categoryInput, $category);
        $entityManager->flush();

        return $this->json($category, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Category $category, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($category);
        $entityManager->flush();

        return $this->json(null, 204);
    }
}
