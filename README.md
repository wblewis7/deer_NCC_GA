# deer_NCC_GA
Data and code for assessing the nutritional carrying capacity (NCC) of white-tailed deer (Odocoileus virginianus) in response to mid-rotation timber thinning, spring prescribed burns, and herbicide application at managed pine stands of loblolly pine (Pinus taeda) in central Georgia, USA, 2020 - 2021. Contract Information: William Lewis, wblewis7@gmail.com, University of Georgia
---

---

# Metadata

# deer.NCC.GA.data.gzip
Data for the project are stored in the "deer.NCC.GA.data" gzip file. NCC was assessed at a series of 252 survey locations spread across 5 managed pine stands in Georgia. Stands were divided into three plots and logged in 2017 to either 9.2, 13.8, or 8.4 average m2/ha. Basal area was measured at survey locations in 2017, and basal area in 2020 and 2021 was predicted based on loblolly pine growth and yield equations in Clutter (1963). Plots were divided into subplots, and assigned to either fire or no fire treatments. Prescribed burns were implemented in the springs of 2018 and 2020. Subplots were further divided into sub-subplots and assigned to either herbicide or non-herbicide treatments. In fall 2019, an herbicide mixture was applied via broadcast spraying at herbicide sub-subplots. The mixture consisted of Arsenal, Escort, and RRSI Sunset, representative of commonly used herbicide mixtures on pine plantations in the Southeastern U.S. for site preparation, conifer release, and herbaceous weed control (Shepard et al. 2004). This design led to four different treatment combinations: Control, Fire, Herbicide, or Mix (both fire and herbicide). Forage samples were collected at survey locations in the summers of 2020 and 2021 (i.e., one and two growing seasons post-treatment). Palatable growth was clipped and bagged, and dry biomass was calculated by drying forage samples in industrial-scale drying ovens at 50C and weighing daily until constant mass was recorded for two consecutive days. Nitrogen content was assessed at a subset of forage samples for each combination of plant genus, stand, and treatment. Nitrogen content was assessed using a wet chemistry nitrogen combustion technique, with nitrogen values converted to crude protein percent via a conversion factor of 6.25 (Robbins. 1993). Nutritional carrying capacity was calculated as in Hobbs and Swift (1985) for 6% and 14% crude protein requirements. Forage biomass estimates were divided by the average dry matter intake rate of a lactating female deer weighing 50 kg (2.4 kg dry mass/day; National Research Council. 2007) to calculate NCC.
## NCC.6
Calculated NCC for each survey under a 6% crude protein constraint.
## NCC.14
Calculated NCC for each survey under a 14% crude protein constraint.
## nNCC
Number of NCC surveys across all 252 survey locations and both years (2020/2021). Three locations were only surveyed in one year.
# ba
The projected basal area (m2/ha) at each survey location in each year. Basal area was measured in 2017 and projected to 2020/2021 based on loblolly pine growth and yield equations. Basal area measurements are standardized.
# year
A binary variable representing the year associated with each NCC survey (0 = 2020, 1 = 2021).
# fire
A binary variable indicating if the survey location was assigned to the Fire or Mix treatments (i.e., exposed to prescribed burning in the springs of 2018 and 2020).
# herb
A binary variable indicating if the survey location was assigned to the Herbicide or Mix treatments (i.e., exposed to broadcast application of an herbicide mixture in fall 2019).
# nstands
The number of stands of loblolly pine in which survey locations were located.
# stand
An indexing value giving the stand ID (1 - 5) for each NCC survey.

<br />
<br />

# Deer_NCC_GA.R
R and JAGS code for assessing the effects of mid-rotation timber thinning, prescribed spring burns, herbicide application, and time since treatment on deer NCC in Georgia. Values of NCC were right-skewed (some values over 10x higher than mean), so we analyze NCC values based on a log-Normal regression in a Bayesian framework. We added a small constant (1) to all values to account for calculated NCC values of 0. We model NCC based on stand-specific intercepts and effects of basal area, fire treatment, herbicide treatment, year (2020 or 2021), and interactions between fire and herbicide, fire and year, and herbicide and year. We incorporated interactions between treatments and year to allow for different vegetation responses between the first and second growing seasons post-treatment. Surveys were conducted at the same locations in 2020 and 2021, though we do not model dependence between NCC estimates from the same survey locations due to data limitations (i.e., needing to estimate effects 252 survey locations with only 501 data points). We run models separatley for NCC values calculated using 6% and 14% crude protein requirements.
