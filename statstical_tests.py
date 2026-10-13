import pandas as pd
from scipy import stats
from statsmodels.stats.proportion import proportions_ztest
 
# Google Bigquery import: Including mean, standard deviation and count columsn
df = pd.read_csv(r"C:\Users\mperr\Documents\Python\King\king_data.csv").set_index("abtest_group")
a, b = df.loc["A"], df.loc["B"]
 
# rounds per active day and purchases per player (Welch's t-test)
for name, n in [("rounds_per_active_day", "players_with_activity"), ("purchases", "players")]:
    t, p = stats.ttest_ind_from_stats(a[f"mean_{name}"], a[f"sd_{name}"], a[n],
                                      b[f"mean_{name}"], b[f"sd_{name}"], b[n], equal_var=False)
    print(f"{name}: p = {p:.2e}")
 
# retention (two-proportion z-test): returned players, eligible players for A and B
retention = {
    "D1": ([5_795_634, 1_448_447], [8_170_796, 2_041_762]),
    "D3": ([5_603_781, 1_399_953], [8_026_463, 2_005_534]),
    "D7": ([5_275_018, 1_318_977], [7_709_111, 1_925_737]),
}
for day, (returned, eligible) in retention.items():
    z, p = proportions_ztest(returned, eligible)
    print(f"{day} retention: p = {p:.3f}")
