double calculateSlope(List<double> x, List<double> y) {
  assert(x.length == y.length);
  final n = x.length;
  double sum_x = 0, sum_y = 0, sum_xy = 0, sum_xx = 0;
  for (int i = 0; i < n; i++) {
    sum_x += x[i];
    sum_y += y[i];
    sum_xy += x[i] * y[i];
    sum_xx += x[i] * x[i];
  }
  return (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x);
}

double calculateIntercept(double slope, List<double> x, List<double> y) {
  assert(x.length == y.length);
  final n = x.length;
  double sum_x = 0, sum_y = 0;
  for (int i = 0; i < n; i++) {
    sum_x += x[i];
    sum_y += y[i];
  }
  return (sum_y - slope * sum_x) / n;
}