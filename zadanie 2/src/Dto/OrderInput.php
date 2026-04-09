<?php

namespace App\Dto;

use App\Entity\Order;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\ObjectMapper\Attribute\Map;

#[Map(target: Order::class)]
class OrderInput
{
    #[Assert\NotBlank]
    #[Assert\Length(max: 255)]
    public string $customerName;

    #[Assert\NotBlank]
    #[Assert\Email]
    #[Assert\Length(max: 255)]
    public string $customerEmail;

    #[Assert\NotBlank]
    #[Assert\Length(max: 50)]
    public string $status = 'pending';

    #[Assert\Type('array')]
    public array $productIds = [];
}
