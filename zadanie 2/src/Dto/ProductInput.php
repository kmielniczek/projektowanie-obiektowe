<?php

namespace App\Dto;

use App\Entity\Product;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\ObjectMapper\Attribute\Map;

#[Map(target: Product::class)]
class ProductInput
{
    #[Assert\NotBlank]
    #[Assert\Length(max: 255)]
    public string $name;

    #[Assert\NotBlank]
    #[Assert\Type('numeric')]
    #[Assert\PositiveOrZero]
    public string $price;

    #[Assert\Positive]
    public ?int $categoryId = null;
}
