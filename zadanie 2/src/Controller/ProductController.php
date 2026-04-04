<?php

namespace App\Controller;

use App\Dto\ProductInput;
use App\Dto\ProductUpdateInput;
use App\Entity\Product;
use App\Repository\ProductRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\ObjectMapper\ObjectMapperInterface;
use Symfony\Component\Routing\Attribute\Route;

#[Route('api/products', name: 'products_', format: 'json')]
final class ProductController extends AbstractController
{
    #[Route('', name: 'list', methods: ['GET'])]
    public function index(ProductRepository $productRepository): JsonResponse
    {
        $products = $productRepository->findAll();

        return $this->json($products, context: ['groups' => 'api']);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(
        #[MapRequestPayload] ProductInput $productInput,
        ObjectMapperInterface $objectMapper,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $product = $objectMapper->map($productInput);
        $entityManager->persist($product);
        $entityManager->flush();

        return $this->json($product, 201, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Product $product): JsonResponse
    {
        return $this->json($product, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT'])]
    public function update(
        #[MapRequestPayload] ProductUpdateInput $productInput,
        Product $product,
        ObjectMapperInterface $objectMapper,
        EntityManagerInterface $entityManager
    ): JsonResponse {
        $objectMapper->map($productInput, $product);
        $entityManager->flush();

        return $this->json($product, context: ['groups' => 'api']);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Product $product, EntityManagerInterface $entityManager): JsonResponse
    {
        $entityManager->remove($product);
        $entityManager->flush();

        return $this->json(null, 204);
    }
}
