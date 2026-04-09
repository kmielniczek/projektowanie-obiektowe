<?php

namespace App\Controller;

use App\Dto\OrderInput;
use App\Dto\OrderUpdateInput;
use App\Entity\Order;
use App\Repository\OrderRepository;
use App\Repository\ProductRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\ObjectMapper\ObjectMapperInterface;
use Symfony\Component\Routing\Attribute\Route;

#[Route('api/orders', name: 'orders_', format: 'json')]
final class OrderController extends AbstractController
{
    #[Route('', name: 'list', methods: ['GET'])]
    public function index(OrderRepository $orderRepository): JsonResponse
    {
        $orders = $orderRepository->findAll();

        return $this->json($orders, context: ['groups' => 'api']);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(
        #[MapRequestPayload] OrderInput $orderInput,
        ObjectMapperInterface $objectMapper,
        ProductRepository $productRepository,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $order = $objectMapper->map($orderInput);

        foreach ($orderInput->productIds as $productId) {
            $product = $productRepository->find($productId);

            if (!$product) {
                return $this->json(['error' => "Product with id $productId not found."], 404);
            }

            $order->addProduct($product);
        }

        $order->setTotalPrice($this->calculateTotalPrice($order->getProducts()));

        $entityManager->persist($order);
        $entityManager->flush();

        return $this->json($order, 201, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Order $order): JsonResponse
    {
        return $this->json($order, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT'])]
    public function update(
        #[MapRequestPayload] OrderUpdateInput $orderInput,
        Order $order,
        ObjectMapperInterface $objectMapper,
        ProductRepository $productRepository,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $objectMapper->map($orderInput, $order);

        if (is_array($orderInput->productIds)) {
            $order->clearProducts();

            foreach ($orderInput->productIds as $productId) {
                $product = $productRepository->find($productId);

                if (!$product) {
                    return $this->json(['error' => "Product with id $productId not found."], 404);
                }

                $order->addProduct($product);
            }

            $order->setTotalPrice($this->calculateTotalPrice($order->getProducts()));
        }

        $entityManager->flush();

        return $this->json($order, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Order $order, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($order);
        $entityManager->flush();

        return $this->json(null, 204);
    }

    private function calculateTotalPrice(iterable $products): string
    {
        $total = '0.00';

        foreach ($products as $product) {
            $total = bcadd($total, $product->getPrice(), 2);
        }

        return $total;
    }
}
