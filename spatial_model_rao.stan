data {
  int<lower=0> N;                // Number of countries
  int<lower=0> n_years;          // Number of years
  matrix[N, n_years] pm25;       // PM2.5 matrix
  int annex[N];                  // Annex status
  int<lower=0> J;               // Number of countries
  int<lower=1, upper=J> country_id[N]; 
  int<lower=0> K;               // Number of regions
  int<lower=1, upper=K> region_id[N];
  vector[n_years] year_c;       // Centered years
}

parameters {
  real alpha;
  real beta_year;
  real beta_annex;
  real beta_interaction;
  
  // Random effects
  vector[J] z_country;
  vector[K] z_region;
  real<lower=0> sigma_country;
  real<lower=0> sigma_region;
  
  real<lower=0> sigma;
}

transformed parameters {
  vector[J] country_effect = z_country * sigma_country;
  vector[K] region_effect = z_region * sigma_region;
  
  matrix[N, n_years] mu;
  for (i in 1:N) {
    for (t in 1:n_years) {
      mu[i,t] = alpha + 
                beta_year * year_c[t] + 
                beta_annex * annex[i] + 
                beta_interaction * year_c[t] * annex[i] + 
                country_effect[country_id[i]] + 
                region_effect[region_id[i]];
    }
  }
}

model {
  // Priors
  alpha ~ normal(0, 5);
  beta_year ~ normal(0, 2);
  beta_annex ~ normal(0, 2);
  beta_interaction ~ normal(0, 2);
  sigma ~ exponential(1);
  
  // Random effects
  z_country ~ std_normal();
  z_region ~ std_normal();
  sigma_country ~ exponential(1);
  sigma_region ~ exponential(1);
  
  // Likelihood
  for (i in 1:N) {
    pm25[i,] ~ normal(mu[i,], sigma);
  }
}

generated quantities {
  matrix[N, n_years] y_rep;
  for (i in 1:N) {
    for (t in 1:n_years) {
      y_rep[i,t] = normal_rng(mu[i,t], sigma);
    }
  }
}