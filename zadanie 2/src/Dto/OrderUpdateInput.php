<?php

namespace App\Dto;

use App\Entity\Order;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\ObjectMapper\Attribute\Map;

#[Map(target: Order::class)]
class OrderUpdateInput
{
    #[Assert\Length(max: 255)]
    public ?string $customerName;

    #[Assert\Email]
    #[Assert\Length(max: 255)]
    public ?string $customerEmail;

    #[Assert\Length(max: 50)]
    public ?string $status;

    #[Assert\Type('array')]
    public ?array $productIds = null;
}
