String classifyAcidity(double ta) {
  if (ta < 4.5) return "Low – Sweet apples";
  if (ta <= 7.5) return "Medium – Balanced: ideal for cider";
  if (ta <= 11.0) return "High – Many table apples";
  return "Very high – Cooking apples, crabs";
}
