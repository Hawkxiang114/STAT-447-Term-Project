data {
  int<lower=0> N; # Total observations
  vector[N] pm25; # pm2.5 measurements
  vector[N] year; # Centered years (year - 1970)
  int annex[N]; # Annex status (1 = Annex, 0 = Non-Annex)
  int<lower=0> J; # Number of unique countries
  int<lower=1, upper=J> country_id[N]; # Country IDs (1..J)
  int<lower=0> K; # Number of regions
  int<lower=1, upper=K> region_id[N]; # Region IDs (1..K)
}

parameters {
  # Fixed effect
  real alpha; # Intercept (baseline pm2.5)
  real beta_year; # Effect of time (year)
  real beta_annex; # Effect of Annex I status
  real beta_interaction; # Interaction: Year × Annex I
  
  # Random effects
  vector[J] z_country; # Standardized country random effects
  vector[K] z_region; # Standardized region random effects
  real<lower=0> sigma_country; # SD of country effects
  real<lower=0> sigma_region; # SD of region effects
  
  real<lower=0> sigma; # Residual error SD
}

transformed parameters {
  # Non-centered parameterization
  vector[J] country_effect = z_country * sigma_country;
  vector[K] region_effect = z_region * sigma_region;
  
  # Linear predictor
  vector[N] mu;
  for (n in 1:N) {
    mu[n] = alpha + 
            beta_year * year[n] + 
            beta_annex * annex[n] + 
            beta_interaction * year[n] * annex[n] + 
            country_effect[country_id[n]] + 
            region_effect[region_id[n]];
  }
}

model {
  # Priors
  alpha ~ normal(0, 5);
  beta_year ~ normal(0, 2);
  beta_annex ~ normal(0, 2);
  beta_interaction ~ normal(0, 2);
  sigma ~ exponential(1);
  
  # Random effects
  z_country ~ std_normal();
  z_region ~ std_normal();
  sigma_country ~ exponential(1);
  sigma_region ~ exponential(1);
  
  # Likelihood
  pm25 ~ normal(mu, sigma);
}

generated quantities {
  # Posterior predictive checks
  vector[N] y_rep;
  for (n in 1:N) {
    y_rep[n] = normal_rng(mu[n], sigma);
  }
}
