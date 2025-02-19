# R and JAGS code for assessing the effects of mid-rotation timber thinning intensity,
#   spring prescribed burns, and herbicide application on the nutritional carrying
#   capacity (NCC) of white-tailed deer (Odocoileus virginianus) at managed stands
#   of loblolly pine (Pinus taeda) in central Georgia, USA, 2020 - 2021.
# Contact: Will Lewis, wblewis7@gmail.com, University of Georgia

# NCC was assessed at a series of 252 survey locations spread across 5 managed pine stands
#   in Georgia. Stands were divided into three plots and logged in 2017 to either 9.2, 13.8,
#   or 8.4 average m2/ha. Basal area was measured at survey locations in 2017, and basal area in 2020
#   and 2021 was predicted based on loblolly pine growth and yield equations in Clutter (1963.
#   Compatible growth and yield models for loblolly pine). Plots were divided into subplots, 
#   and assigned to either fire or no fire treatments. Prescribed burns were implemented in 
#   the springs of 2018 and 2020. Subplots were further divided into sub-subplots and assigned
#   to either herbicide or non-herbicide treatments. In fall 2019, an herbicide mixture was 
#   applied via broadcast spraying at herbicide sub-subplots. The mixture consisted of  
#   Arsenal, Escort, and RRSI Sunset, representative of commonly used herbicide
#   mixtures on pine plantations in the Southeastern U.S. for site preparation,
#   conifer release, and herbaceous weed control (Shepard et al. 2004. Forestry herbicides 
#   in the United States: An overview). This design led to four different treatment combinations:
#   Control, Fire, Herbicide, or Mix (both fire and herbicide).
# Forage samples were collected at survey locations in the summers of 2020 and 2021 (i.e., one and
#   two growing seasons post-treatment). Palatable growth was clipped and bagged, and dry biomass
#   was calculated by drying forage samples in industrial-scale drying ovens at 50C and weighing
#   daily until constant mass was recorded for two consecutive days. Nitrogen content was assessed
#   at a subset of forage samples for each combination of plant genus, stand, and treatment.
#   Nitrogen content was assessed using a wet chemistry nitrogen combustion technique, with nitrogen
#   values converted to crude protein percent via a conversion factor of 6.25 (Robbins. 1993. Wildlife
#   feeding and Nutrition). Nutritional carrying capacity was calculated as in Hobbs and Swift (1985. 
#   Estimates of habitat carrying capacity incorporating explicit nutritional constraints) for 6%
#   and 14% crude protein requirements. Forage biomass estimates were divided by the average
#   dry matter intake rate of a lactating female deer weighing 50 kg (2.4 kg dry mass/day;
#   National Research Council 2007) to calculate NCC.
# Values of NCC were right-skewed (some values over 10x higher than mean), so we analyze
#   NCC values based on a log-Normal regression in a Bayesian framework. We model NCC
#   based on stand-specific intercepts and effects of basal area, fire treatment, herbicide
#   treatment, year (2020 or 2021), and interactions between fire and herbicide, fire and 
#   year, and herbicide and year. We incorporated interactions between treatments and year
#   to allow for different vegetation responses between the first and second growing seasons
#   post-treatment.


require(rjags)



load("deer.NCC.GA.data.gzip")




sink("deerNCC_model.jags")
cat("
    model{

  for(s in 1:nstands){
    b_stand[s] ~ dnorm(0, standprec)
  }
  standsd ~ dunif(0, 100)
  standprec <- 1/(standsd*standsd)
  mu.sd ~ dunif(0, 100)
  mu.prec <- 1/(mu.sd*mu.sd)
  
  b_ba ~ dnorm(0, 0.001)
  b_fire ~ dnorm(0, 0.001)
  b_herb ~ dnorm(0, 0.001)
  b_herb_fire ~ dnorm(0, 0.001)
  b_yr ~ dnorm(0, 0.001)
  b_yr_fire ~ dnorm(0, 0.001)
  b_yr_herb ~ dnorm(0, 0.001)
  
  
  for(i in 1:nNCC){
    mu[i] <- b_stand[stand[i]] + b_ba*ba[i] + b_fire*fire[i] + b_herb*herb[i] + b_herb_fire*fire[i]*herb[i] + b_yr*year[i] + b_yr_fire*year[i]*fire[i] + b_yr_herb*year[i]*herb[i]
    NCC[i] ~ dlnorm(mu[i], mu.prec)
  }
  
  # Deriving average intercept effect across stands for predicting
  b0 <- sum(b_stand[1:nstands])/nstands
  
  # Deriving average year effect across 2020 and 2021 for predicting. 2020 is baseline,
  #   so just dividing 2021 effect (b_yr) by 2.
  b_yravg <- b_yr/2
    
    }
    ",fill=TRUE)
sink()



deerNCC.inits.fun <- function() list(mu.sd=runif(1,0.00001,2),
                                              b_ba=runif(1,-2,2),
                                              b_fire=runif(1,-2,2),
                                              b_herb=runif(1,-2,2),
                                              b_herb_fire=runif(1,-2,2),
                                              b_yr=runif(1,-2,2),
                                              b_yr_fire=runif(1,-2,2),
                                              b_yr_herb=runif(1,-2,2),
                                              b_stand=runif(NCC.data.6$nstands,10,20),
                                              standsd=runif(1,0.001,1))

params.deerNCC <- c("b0","b_ba","b_fire","b_herb","b_herb_fire",
                    "mu.sd","b_stand","b_yr","b_yr_fire",
                    "b_yr_herb","b_yravg")



# 6% crude protein requirements
NCC.data.6 <- deer.NCC.GA.data[names(deer.NCC.GA.data) != "NCC.14"]
names(NCC.data.6)[1] <- "NCC"
NOBO.deerNCC.6.model <- jags.model(data=NCC.data.6, inits = deerNCC.inits.fun, 
                                            file='deerNCC_model.jags',
                                            n.chain = 3, n.adapt = 5000)
NOBO.deerNCC.6.model.cs <- coda.samples(NOBO.deerNCC.6.model, variable.names=params.deerNCC,
                                                 n.iter=50000, n.burn=5000, thin=5)



# 14% crude protein requirements
NCC.data.14 <- deer.NCC.GA.data[names(deer.NCC.GA.data) != "NCC.6"]
names(NCC.data.14)[1] <- "NCC"
NOBO.deerNCC.14.model <- jags.model(data=NCC.data.14, inits = deerNCC.inits.fun, 
                                   file='deerNCC_model.jags',
                                   n.chain = 3, n.adapt = 5000)
NOBO.deerNCC.14.model.cs <- coda.samples(NOBO.deerNCC.14.model, variable.names=params.deerNCC,
                                        n.iter=50000, n.burn=5000, thin=5)