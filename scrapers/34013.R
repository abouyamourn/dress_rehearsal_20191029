library(ygresults)
library(stringr)
library(dplyr)

ELECTION_CODE <- "test_20181029"
COUNTY_CODE <- "34013"

raw <- raw_download(ELECTION_CODE, COUNTY_CODE) %>%
    mutate(district = as.numeric(district), state = as.numeric(state), county = as.numeric(county),
           votes = as.integer(votes))

## precinct names
df <- raw %>%
    mutate(precinct = as.character(precinct))

## candidate names
df <- df %>%
    mutate(candidate = str_replace_all(candidate, " (I+|Jr\\.*|Sr\\.*)$", "") %>%
               str_extract("((De|La) )*(\\w|-|')+$") %>%
               capitalize_names()
    )

## party
df <- df %>%
    mutate(party = recode(party, "Gre" = "Grn") %>% tidyr::replace_na('Oth'))

out <- df %>% select(precinct, district, office, candidate, party, votetype, votes)

out %>% results_schema(COUNTY_CODE)

out %>% results_upload(election_code = ELECTION_CODE,
                       county_code = COUNTY_CODE)
