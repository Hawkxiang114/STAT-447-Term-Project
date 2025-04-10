data {
  int<lower=0> N;
  vector[N] pm25;
  vector[N] year;
  int annex[N];
  int<lower=0> J;
  int<lower=1, upper=J> country[N];
  int<lower=0> K;
  int<lower=1, upper=K> region[N];
}

parameters {
  real alpha;
  real beta_year;
  real beta_annex;
  real beta_interaction;
  vector[J] country_effect;
  vector[K] region_effect;
  real<lower=0> sigma;
  real<lower=0> sigma_country;
  real<lower=0> sigma_region;
}

model {
  // Priors
  alpha ~ normal(0, 10);
  beta_year ~ normal(0, 5);
  beta_annex ~ normal(0, 5);
  beta_interaction ~ normal(0, 5);
  sigma ~ exponential(1);
  sigma_country ~ exponential(1);
  sigma_region ~ exponential(1);
  
  // Random effects
  country_effect ~ normal(0, sigma_country);
  region_effect ~ normal(0, sigma_region);
  
  // Likelihood
  for(n in 1:N) {
    pm25[n] ~ normal(
      alpha + 
      beta_year * year[n] + 
      beta_annex * annex[n] + 
      beta_interaction * year[n] * annex[n] + 
      country_effect[country[n]] + 
      region_effect[region[n]], 
      sigma
    );
  }
}

generated quantities {
  vector[N] y_rep;
  for(n in 1:N) {
    y_rep[n] = normal_rng(
      alpha + 
      beta_year * year[n] + 
      beta_annex * annex[n] + 
      beta_interaction * year[n] * annex[n] + 
      country_effect[country[n]] + 
      region_effect[region[n]], 
      sigma
    );
  }
}


