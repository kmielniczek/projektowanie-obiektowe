<?php

namespace App\Dto;

use App\Entity\Product;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\ObjectMapper\Attribute\Map;

#[Map(target: Product::class)]
class ProductUpdateInput
{
    #[Assert\Length(max: 255)]
    public ?string $name;

    #[Assert\Type('numeric')]
    #[Assert\PositiveOrZero]
    public ?string $price;
}
