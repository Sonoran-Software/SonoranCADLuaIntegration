export function convertSubNumToName(subLevel: number) {
  switch (subLevel) {
    case 0:
      return 'FREE';
    case 1:
      return 'STARTER';
    case 2:
      return 'STANDARD';
    case 3:
      return 'PLUS';
    case 4:
      return 'PRO';
    case 6:
      return 'ONE';
    default:
      return 'FREE';
  }
}