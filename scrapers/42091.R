library(ygresults)
library(stringr)
library(dplyr)

options(parallel_packing = F)

ELECTION_CODE <- "test_20181029"
COUNTY_CODE <- "42091"

schema_precincts(COUNTY_CODE)


raw <- raw_download(ELECTION_CODE, COUNTY_CODE) %>%
    mutate(district = as.numeric(district), state = as.numeric(state), county = as.numeric(county),
           votes = as.integer(votes))

head(raw)

## precinct names
df <- raw %>%
    mutate(precinct = as.character(precinct))

df$precinct <- str_replace_all(df$precinct, "-[0-9][0-9][0-9][0-9]", "")

tail(df, 100)

df <- df %>% mutate(precinct = as.character(precinct))

## candidate names
df <- df %>%
    mutate(candidate = str_replace_all(candidate, "(I+|, JR\\.*|, SR\\.*)$", "") %>%
               str_extract("((De|La) )*(\\w|-|'|,)+$") %>%
               capitalize_names()
    )

## party
df <- df %>%
    mutate(party = recode(party, "Gre" = "Grn") %>% tidyr::replace_na('Oth'))

out <- df %>% select(precinct, district, office, candidate, party, votetype, votes)

out %>% results_schema(COUNTY_CODE)

out

unique(out$precinct)

out %>% results_upload(election_code = ELECTION_CODE,
                       county_code = COUNTY_CODE)
