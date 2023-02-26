enum OrderStatus {
  iniciado(label: "Iniciado"),
  andamento(label: 'Em andamento'),
  finalizado(label: 'Finalizado'),
  emRota(label: 'Em Rota'),
  completo(label: 'Completo');

  final String label;
  const OrderStatus({required this.label});
}
