struct Point {
  xOut: Field,
  yOut: Field,
}

global a = 168700;
global d = 168696;

fn babyAdd(
  x1: Field,
  y1: Field,
  x2: Field,
  y2: Field,
) -> Point {

  let beta = x1 * y2;
  let gamma = x2 * y1;
  let delta = (-a*x1+y1)*(x2 + y2);
  let tau = beta * gamma;

  let xOut = (beta + gamma) / (1+ d*tau);

  let yOut = (delta + a*beta - gamma) / (1-d*tau);
  
  Point {
    xOut,
    yOut,
  }
}

fn babyDbl(x: Field, y: Field) -> Point {
  let out = babyAdd(x, y, x, y);
  out
}

fn babyCheck(x: Field, y: Field) {
  let y2 = y * y;
  let x2 = x * x;
  assert(a*x2 + y2 == 1 + d*x2*y2);
}

