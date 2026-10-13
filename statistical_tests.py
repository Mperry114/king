import pandas as pd
from scipy import stats
from statsmodels.stats.proportion import proportions_ztest
 
df = pd.read_csv(r"C:\Users\mperr\Documents\Python\King\king_data.csv").set_index("abtest_group")
a, b = df.loc["A"], df.loc["B"]
 
for m in ["purchases", "gamerounds", "active_days"]:
    p = stats.ttest_ind_from_stats(a[f"mean_{m}"], a[f"sd_{m}"], a["players"],
                                   b[f"mean_{m}"], b[f"sd_{m}"], b["players"], equal_var=False).pvalue
    print(m, p)
 
for d in ["d1", "d3", "d7"]:
    p = proportions_ztest([a[f"{d}_returned"], b[f"{d}_returned"]], [a[f"{d}_eligible"], b[f"{d}_eligible"]])[1]
    print(d, p)
 
