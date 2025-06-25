data {
  int<lower=1> n;
  int<lower=1> k;
  array[n] simplex[k] y;
  array[n] int<lower=0, upper=1> group;
}

parameters {
  vector<lower=0>[k] alpha_non_smoker;
  vector<lower=0>[k] alpha_smoker;
}

model {
  alpha_non_smoker ~ exponential(1);
  alpha_smoker ~ exponential(1);

  for (i in 1:n) {
    if (group[i] == 0)
      y[i] ~ dirichlet(alpha_non_smoker);
    else
      y[i] ~ dirichlet(alpha_smoker);
  }
}

