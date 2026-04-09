<?php

namespace App\Dto;

use App\Entity\Category;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\ObjectMapper\Attribute\Map;

#[Map(target: Category::class)]
class CategoryInput
{
    #[Assert\NotBlank]
    #[Assert\Length(max: 255)]
    public string $name;

    #[Assert\Length(max: 1000)]
    public ?string $description = null;
}
