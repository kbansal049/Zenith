/*
 * This class is generated dynamically from Patch Rules.
 */
global class PatchRuleEngine3 extends  PatchRuleEngineBase implements IPatchRuleEngine
{
  private Id matchGroup1(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a314u00000NyTcTAAV') || prematches.get('Email Domain').contains('a314u00000NyTcUAAV'))      return 'a304u000002pkiQAAQ'; //Patch Health TOLA - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUJAA3') || prematches.get('Email Domain').contains('a314u00000NyTUKAA3'))      return 'a304u000002pkiRAAQ'; //Patch CSR Health North - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTULAA3') || prematches.get('Email Domain').contains('a314u00000NyTUMAA3'))      return 'a304u000002pkiSAAQ'; //Patch CSR Health South - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUNAA3') || prematches.get('Email Domain').contains('a314u00000NyTUOAA3'))      return 'a304u000002pkiTAAQ'; //Patch CSR Health West - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUZAA3') || prematches.get('Email Domain').contains('a314u00000NyTUaAAN'))      return 'a304u000002pkiUAAQ'; //Patch CSR SLED North Central - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUbAAN') || prematches.get('Email Domain').contains('a314u00000NyTUcAAN'))      return 'a304u000002pkiVAAQ'; //Patch CSR SLED North East - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUdAAN') || prematches.get('Email Domain').contains('a314u00000NyTUeAAN'))      return 'a304u000002pkiWAAQ'; //Patch CSR SLED North West - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUfAAN') || prematches.get('Email Domain').contains('a314u00000NyTUgAAN'))      return 'a304u000002pkiXAAQ'; //Patch CSR SLED South Central - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUhAAN') || prematches.get('Email Domain').contains('a314u00000NyTUiAAN'))      return 'a304u000002pkiYAAQ'; //Patch CSR SLED South East 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUjAAN') || prematches.get('Email Domain').contains('a314u00000NyTUkAAN'))      return 'a304u000002pkiZAAQ'; //Patch CSR SLED South East 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTUlAAN') || prematches.get('Email Domain').contains('a314u00000NyTUmAAN'))      return 'a304u000002pkiaAAA'; //Patch CSR SLED South West - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTRrAAN') || prematches.get('Email Domain').contains('a314u00000NyTRsAAN'))      return 'a304u000002pkibAAA'; //Patch Catch All Health Comm - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTRtAAN') || prematches.get('Email Domain').contains('a314u00000NyTRuAAN'))      return 'a304u000002pkicAAA'; //Patch Catch All Health East - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTRvAAN') || prematches.get('Email Domain').contains('a314u00000NyTRwAAN'))      return 'a304u000002pkidAAA'; //Patch Catch All Health West - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTThAAN') || prematches.get('Email Domain').contains('a314u00000NyTTiAAN'))      return 'a304u000002pkieAAA'; //Patch Catch All SLED Comm - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTTzAAN') || prematches.get('Email Domain').contains('a314u00000NyTU0AAN'))      return 'a304u000002pkifAAA'; //Patch Catch All US SLED Central - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTU1AAN') || prematches.get('Email Domain').contains('a314u00000NyTU2AAN'))      return 'a304u000002pkigAAA'; //Patch Catch All US SLED East - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTU3AAN') || prematches.get('Email Domain').contains('a314u00000NyTU4AAN'))      return 'a304u000002pkihAAA'; //Patch Catch All US SLED South - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTU5AAN') || prematches.get('Email Domain').contains('a314u00000NyTU6AAN'))      return 'a304u000002pkiiAAA'; //Patch Catch All US SLED West - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmpAAF') || prematches.get('Email Domain').contains('a314u00000NyTmqAAF'))      return 'a304u000002pkijAAA'; //Patch Major Canada PS 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTdpAAF') || prematches.get('Email Domain').contains('a314u00000NyTdqAAF'))      return 'a304u000002pkikAAA'; //Patch LE Canada PS 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTdrAAF') || prematches.get('Email Domain').contains('a314u00000NyTdsAAF'))      return 'a304u000002pkilAAA'; //Patch LE Canada PS 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTdtAAF') || prematches.get('Email Domain').contains('a314u00000NyTduAAF'))      return 'a304u000002pkimAAA'; //Patch LE Canada PS 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTdvAAF') || prematches.get('Email Domain').contains('a314u00000NyTdwAAF'))      return 'a304u000002pkinAAA'; //Patch LE Canada PS 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTU9AAN') || prematches.get('Email Domain').contains('a314u00000NyTUAAA3'))      return 'a304u000002pkioAAA'; //Patch CSR Canada PS 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTQLAA3') || prematches.get('Email Domain').contains('a314u00000NyTQMAA3'))      return 'a304u000002pkipAAA'; //Patch Catch All Canada PS - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrnAAF') || prematches.get('Email Domain').contains('a314u00000NyTroAAF'))      return 'a304u000002pkiqAAA'; //Patch Strategic ANZ North 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrpAAF') || prematches.get('Email Domain').contains('a314u00000NyTrqAAF'))      return 'a304u000002pkirAAA'; //Patch Strategic ANZ North 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrrAAF') || prematches.get('Email Domain').contains('a314u00000NyTrsAAF'))      return 'a304u000002pkisAAA'; //Patch Strategic ANZ South 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrtAAF') || prematches.get('Email Domain').contains('a314u00000NyTruAAF'))      return 'a304u000002pkitAAA'; //Patch Strategic ANZ South 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrvAAF') || prematches.get('Email Domain').contains('a314u00000NyTrwAAF'))      return 'a304u000002pkiuAAA'; //Patch Strategic Carolinas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrxAAF') || prematches.get('Email Domain').contains('a314u00000NyTryAAF'))      return 'a304u000002pkivAAA'; //Patch Strategic CEUR 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTrzAAF') || prematches.get('Email Domain').contains('a314u00000NyTs0AAF'))      return 'a304u000002pkiwAAA'; //Patch Strategic CEUR 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTs1AAF') || prematches.get('Email Domain').contains('a314u00000NyTs2AAF'))      return 'a304u000002pkixAAA'; //Patch Strategic CEUR 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTs3AAF') || prematches.get('Email Domain').contains('a314u00000NyTs4AAF'))      return 'a304u000002pkiyAAA'; //Patch Strategic CEUR 04 - Named Accounts
    return null;
  }
  private Id matchGroup2(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a314u00000NyTs5AAF') || prematches.get('Email Domain').contains('a314u00000NyTs6AAF'))      return 'a304u000002pkizAAA'; //Patch Strategic CEUR 05 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTs7AAF') || prematches.get('Email Domain').contains('a314u00000NyTs8AAF'))      return 'a304u000002pkj0AAA'; //Patch Strategic Chicago 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTs9AAF') || prematches.get('Email Domain').contains('a314u00000NyTsAAAV'))      return 'a304u000002pkj1AAA'; //Patch Strategic France 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsBAAV') || prematches.get('Email Domain').contains('a314u00000NyTsCAAV'))      return 'a304u000002pkj2AAA'; //Patch Strategic France 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsDAAV') || prematches.get('Email Domain').contains('a314u00000NyTsEAAV'))      return 'a304u000002pkj3AAA'; //Patch Strategic India 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsFAAV') || prematches.get('Email Domain').contains('a314u00000NyTsGAAV'))      return 'a304u000002pkj4AAA'; //Patch Strategic India 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsHAAV') || prematches.get('Email Domain').contains('a314u00000NyTsIAAV'))      return 'a304u000002pkj5AAA'; //Patch Strategic India 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsJAAV') || prematches.get('Email Domain').contains('a314u00000NyTsKAAV'))      return 'a304u000002pkj6AAA'; //Patch Strategic India 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsLAAV') || prematches.get('Email Domain').contains('a314u00000NyTsMAAV'))      return 'a304u000002pkj7AAA'; //Patch Strategic Japan 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsNAAV') || prematches.get('Email Domain').contains('a314u00000NyTsOAAV'))      return 'a304u000002pkj8AAA'; //Patch Strategic Japan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsPAAV') || prematches.get('Email Domain').contains('a314u00000NyTsQAAV'))      return 'a304u000002pkj9AAA'; //Patch Strategic Japan 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsRAAV') || prematches.get('Email Domain').contains('a314u00000NyTsSAAV'))      return 'a304u000002pkjAAAQ'; //Patch Strategic Japan 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsTAAV') || prematches.get('Email Domain').contains('a314u00000NyTsUAAV'))      return 'a304u000002pkjBAAQ'; //Patch Strategic NY/NJ 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsVAAV') || prematches.get('Email Domain').contains('a314u00000NyTsWAAV'))      return 'a304u000002pkjCAAQ'; //Patch Strategic NY/NJ 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsXAAV') || prematches.get('Email Domain').contains('a314u00000NyTsYAAV'))      return 'a304u000002pkjDAAQ'; //Patch Strategic NY/NJ 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsZAAV') || prematches.get('Email Domain').contains('a314u00000NyTsaAAF'))      return 'a304u000002pkjEAAQ'; //Patch Strategic NY/NJ 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsbAAF') || prematches.get('Email Domain').contains('a314u00000NyTscAAF'))      return 'a304u000002pkjFAAQ'; //Patch Strategic TN 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsdAAF') || prematches.get('Email Domain').contains('a314u00000NyTseAAF'))      return 'a304u000002pkjGAAQ'; //Patch Strategic UK&I 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsfAAF') || prematches.get('Email Domain').contains('a314u00000NyTsgAAF'))      return 'a304u000002pkjHAAQ'; //Patch Strategic UK&I 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTshAAF') || prematches.get('Email Domain').contains('a314u00000NyTsiAAF'))      return 'a304u000002pkjIAAQ'; //Patch Strategic UK&I 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsjAAF') || prematches.get('Email Domain').contains('a314u00000NyTskAAF'))      return 'a304u000002pkjJAAQ'; //Patch Strategic UK&I 04 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTslAAF') || prematches.get('Email Domain').contains('a314u00000NyTsmAAF'))      return 'a304u000002pkjKAAQ'; //Patch Strategic West 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTsnAAF') || prematches.get('Email Domain').contains('a314u00000NyTsoAAF'))      return 'a304u000002pkjLAAQ'; //Patch Strategic West 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTspAAF') || prematches.get('Email Domain').contains('a314u00000NyTsqAAF'))      return 'a304u000002pkjMAAQ'; //Patch Strategic West 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTQ1AAN') || prematches.get('Email Domain').contains('a314u00000NyTQ2AAN'))      return 'a304u000002pkjNAAQ'; //Patch Catch All ANZ Strategic - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTSXAA3') || prematches.get('Email Domain').contains('a314u00000NyTSYAA3'))      return 'a304u000002pkjOAAQ'; //Patch Catch All Japan Major Strategic - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTSfAAN') || prematches.get('Email Domain').contains('a314u00000NyTSgAAN'))      return 'a304u000002pkjPAAQ'; //Patch Catch All Japan Strategic - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmHAAV') || prematches.get('Email Domain').contains('a314u00000NyTmIAAV'))      return 'a304u000002pkjQAAQ'; //Patch Major ANZ Govt 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmJAAV') || prematches.get('Email Domain').contains('a314u00000NyTmKAAV'))      return 'a304u000002pkjRAAQ'; //Patch Major ANZ Govt 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmLAAV') || prematches.get('Email Domain').contains('a314u00000NyTmMAAV'))      return 'a304u000002pkjSAAQ'; //Patch Major ANZ Govt 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmNAAV') || prematches.get('Email Domain').contains('a314u00000NyTmOAAV'))      return 'a304u000002pkjTAAQ'; //Patch Major ANZ North 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmPAAV') || prematches.get('Email Domain').contains('a314u00000NyTmQAAV'))      return 'a304u000002pkjUAAQ'; //Patch Major ANZ North 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmRAAV') || prematches.get('Email Domain').contains('a314u00000NyTmSAAV'))      return 'a304u000002pkjVAAQ'; //Patch Major ANZ South 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmTAAV') || prematches.get('Email Domain').contains('a314u00000NyTmUAAV'))      return 'a304u000002pkjWAAQ'; //Patch Major ANZ South 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmVAAV') || prematches.get('Email Domain').contains('a314u00000NyTmWAAV'))      return 'a304u000002pkjXAAQ'; //Patch Major ASEAN 1 - Named Accounts
    return null;
  }
  private Id matchGroup3(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a314u00000NyTmXAAV') || prematches.get('Email Domain').contains('a314u00000NyTmYAAV'))      return 'a304u000002pkjYAAQ'; //Patch Major ASEAN 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmZAAV') || prematches.get('Email Domain').contains('a314u00000NyTmaAAF'))      return 'a304u000002pkjZAAQ'; //Patch Major ASEAN 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmbAAF') || prematches.get('Email Domain').contains('a314u00000NyTmcAAF'))      return 'a304u000002pkjaAAA'; //Patch Major ASEAN 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmdAAF') || prematches.get('Email Domain').contains('a314u00000NyTmeAAF'))      return 'a304u000002pkjbAAA'; //Patch Major BeLux 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmfAAF') || prematches.get('Email Domain').contains('a314u00000NyTmgAAF'))      return 'a304u000002pkjcAAA'; //Patch Major Brazil 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmhAAF') || prematches.get('Email Domain').contains('a314u00000NyTmiAAF'))      return 'a304u000002pkjdAAA'; //Patch Major Canada Ontario 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmjAAF') || prematches.get('Email Domain').contains('a314u00000NyTmkAAF'))      return 'a304u000002pkjeAAA'; //Patch Major Canada Ontario 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmlAAF') || prematches.get('Email Domain').contains('a314u00000NyTmmAAF'))      return 'a304u000002pkjfAAA'; //Patch Major Canada Ontario 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmnAAF') || prematches.get('Email Domain').contains('a314u00000NyTmoAAF'))      return 'a304u000002pkjgAAA'; //Patch Major Canada Ontario 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmrAAF') || prematches.get('Email Domain').contains('a314u00000NyTmsAAF'))      return 'a304u000002pkjhAAA'; //Patch Major Carolinas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmtAAF') || prematches.get('Email Domain').contains('a314u00000NyTmuAAF'))      return 'a304u000002pkjiAAA'; //Patch Major Carolinas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmvAAF') || prematches.get('Email Domain').contains('a314u00000NyTmwAAF'))      return 'a304u000002pkjjAAA'; //Patch Major Carolinas 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmxAAF') || prematches.get('Email Domain').contains('a314u00000NyTmyAAF'))      return 'a304u000002pkjkAAA'; //Patch Major Central Texas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTmzAAF') || prematches.get('Email Domain').contains('a314u00000NyTn0AAF'))      return 'a304u000002pkjlAAA'; //Patch Major CEUR 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTn1AAF') || prematches.get('Email Domain').contains('a314u00000NyTn2AAF'))      return 'a304u000002pkjmAAA'; //Patch Major CEUR 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTn3AAF') || prematches.get('Email Domain').contains('a314u00000NyTn4AAF'))      return 'a304u000002pkjnAAA'; //Patch Major CEUR 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTn5AAF') || prematches.get('Email Domain').contains('a314u00000NyTn6AAF'))      return 'a304u000002pkjoAAA'; //Patch Major CEUR 04 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTn7AAF') || prematches.get('Email Domain').contains('a314u00000NyTn8AAF'))      return 'a304u000002pkjpAAA'; //Patch Major CEUR 05 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTn9AAF') || prematches.get('Email Domain').contains('a314u00000NyTnAAAV'))      return 'a304u000002pkjqAAA'; //Patch Major CEUR 06 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnBAAV') || prematches.get('Email Domain').contains('a314u00000NyTnCAAV'))      return 'a304u000002pkjrAAA'; //Patch Major CEUR 07 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnDAAV') || prematches.get('Email Domain').contains('a314u00000NyTnEAAV'))      return 'a304u000002pkjsAAA'; //Patch Major CEUR 08 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnFAAV') || prematches.get('Email Domain').contains('a314u00000NyTnGAAV'))      return 'a304u000002pkjtAAA'; //Patch Major CEUR 09 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnHAAV') || prematches.get('Email Domain').contains('a314u00000NyTnIAAV'))      return 'a304u000002pkjuAAA'; //Patch Major CEUR 10 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnLAAV') || prematches.get('Email Domain').contains('a314u00000NyTnMAAV'))      return 'a304u000002pkjwAAA'; //Patch Major CEUR 12 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnNAAV') || prematches.get('Email Domain').contains('a314u00000NyTnOAAV'))      return 'a304u000002pkjxAAA'; //Patch Major CEUR 13 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnTAAV') || prematches.get('Email Domain').contains('a314u00000NyTnUAAV'))      return 'a304u000002pkk0AAA'; //Patch Major Chicago 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnVAAV') || prematches.get('Email Domain').contains('a314u00000NyTnWAAV'))      return 'a304u000002pkk1AAA'; //Patch Major Chicago 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnXAAV') || prematches.get('Email Domain').contains('a314u00000NyTnYAAV'))      return 'a304u000002pkk2AAA'; //Patch Major Chicago 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnZAAV') || prematches.get('Email Domain').contains('a314u00000NyTnaAAF'))      return 'a304u000002pkk3AAA'; //Patch Major Dallas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnbAAF') || prematches.get('Email Domain').contains('a314u00000NyTncAAF'))      return 'a304u000002pkk4AAA'; //Patch Major Dallas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTndAAF') || prematches.get('Email Domain').contains('a314u00000NyTneAAF'))      return 'a304u000002pkk5AAA'; //Patch Major Denmark 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnfAAF') || prematches.get('Email Domain').contains('a314u00000NyTngAAF'))      return 'a304u000002pkk6AAA'; //Patch Major Denmark 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnhAAF') || prematches.get('Email Domain').contains('a314u00000NyTniAAF'))      return 'a304u000002pkk7AAA'; //Patch Major FL 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnjAAF') || prematches.get('Email Domain').contains('a314u00000NyTnkAAF'))      return 'a304u000002pkk8AAA'; //Patch Major FL 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnlAAF') || prematches.get('Email Domain').contains('a314u00000NyTnmAAF'))      return 'a304u000002pkk9AAA'; //Patch Major France 01 - Named Accounts
    return null;
  }
  private Id matchGroup4(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a314u00000NyTnnAAF') || prematches.get('Email Domain').contains('a314u00000NyTnoAAF'))      return 'a304u000002pkkAAAQ'; //Patch Major France 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnpAAF') || prematches.get('Email Domain').contains('a314u00000NyTnqAAF'))      return 'a304u000002pkkBAAQ'; //Patch Major France 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnrAAF') || prematches.get('Email Domain').contains('a314u00000NyTnsAAF'))      return 'a304u000002pkkCAAQ'; //Patch Major France 04 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTntAAF') || prematches.get('Email Domain').contains('a314u00000NyTnuAAF'))      return 'a304u000002pkkDAAQ'; //Patch Major France 05 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnvAAF') || prematches.get('Email Domain').contains('a314u00000NyTnwAAF'))      return 'a304u000002pkkEAAQ'; //Patch Major France 06 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnxAAF') || prematches.get('Email Domain').contains('a314u00000NyTnyAAF'))      return 'a304u000002pkkFAAQ'; //Patch Major France 07 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTnzAAF') || prematches.get('Email Domain').contains('a314u00000NyTo0AAF'))      return 'a304u000002pkkGAAQ'; //Patch Major France 08 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTo1AAF') || prematches.get('Email Domain').contains('a314u00000NyTo2AAF'))      return 'a304u000002pkkHAAQ'; //Patch Major France 09 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTo3AAF') || prematches.get('Email Domain').contains('a314u00000NyTo4AAF'))      return 'a304u000002pkkIAAQ'; //Patch Major GA 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTo5AAF') || prematches.get('Email Domain').contains('a314u00000NyTo6AAF'))      return 'a304u000002pkkJAAQ'; //Patch Major GCR HK 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTo7AAF') || prematches.get('Email Domain').contains('a314u00000NyTo8AAF'))      return 'a304u000002pkkKAAQ'; //Patch Major GCR TW 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTo9AAF') || prematches.get('Email Domain').contains('a314u00000NyToAAAV'))      return 'a304u000002pkkLAAQ'; //Patch Major Heartland 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToBAAV') || prematches.get('Email Domain').contains('a314u00000NyToCAAV'))      return 'a304u000002pkkMAAQ'; //Patch Major Heartland 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToDAAV') || prematches.get('Email Domain').contains('a314u00000NyToEAAV'))      return 'a304u000002pkkNAAQ'; //Patch Major Heartland 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToFAAV') || prematches.get('Email Domain').contains('a314u00000NyToGAAV'))      return 'a304u000002pkkOAAQ'; //Patch Major Heartland 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToHAAV') || prematches.get('Email Domain').contains('a314u00000NyToIAAV'))      return 'a304u000002pkkPAAQ'; //Patch Major Houston 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToJAAV') || prematches.get('Email Domain').contains('a314u00000NyToKAAV'))      return 'a304u000002pkkQAAQ'; //Patch Major Iberia 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToLAAV') || prematches.get('Email Domain').contains('a314u00000NyToMAAV'))      return 'a304u000002pkkRAAQ'; //Patch Major Iberia 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToNAAV') || prematches.get('Email Domain').contains('a314u00000NyToOAAV'))      return 'a304u000002pkkSAAQ'; //Patch Major India Govt 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToPAAV') || prematches.get('Email Domain').contains('a314u00000NyToQAAV'))      return 'a304u000002pkkTAAQ'; //Patch Major India Govt 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToRAAV') || prematches.get('Email Domain').contains('a314u00000NyToSAAV'))      return 'a304u000002pkkUAAQ'; //Patch Major India North - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToTAAV') || prematches.get('Email Domain').contains('a314u00000NyToUAAV'))      return 'a304u000002pkkVAAQ'; //Patch Major India South 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToVAAV') || prematches.get('Email Domain').contains('a314u00000NyToWAAV'))      return 'a304u000002pkkWAAQ'; //Patch Major India South 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToXAAV') || prematches.get('Email Domain').contains('a314u00000NyToYAAV'))      return 'a304u000002pkkXAAQ'; //Patch Major India West 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToZAAV') || prematches.get('Email Domain').contains('a314u00000NyToaAAF'))      return 'a304u000002pkkYAAQ'; //Patch Major India West 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTobAAF') || prematches.get('Email Domain').contains('a314u00000NyTocAAF'))      return 'a304u000002pkkZAAQ'; //Patch Major India West 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTodAAF') || prematches.get('Email Domain').contains('a314u00000NyToeAAF'))      return 'a304u000002pkkaAAA'; //Patch Major India West 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTofAAF') || prematches.get('Email Domain').contains('a314u00000NyTogAAF'))      return 'a304u000002pkkbAAA'; //Patch Major Indiana 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTohAAF') || prematches.get('Email Domain').contains('a314u00000NyToiAAF'))      return 'a304u000002pkkcAAA'; //Patch Major Italy 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTojAAF') || prematches.get('Email Domain').contains('a314u00000NyTokAAF'))      return 'a304u000002pkkdAAA'; //Patch Major Italy 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTolAAF') || prematches.get('Email Domain').contains('a314u00000NyTomAAF'))      return 'a304u000002pkkeAAA'; //Patch Major Japan Govt State - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTonAAF') || prematches.get('Email Domain').contains('a314u00000NyTooAAF'))      return 'a304u000002pkkfAAA'; //Patch Major Kansas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTopAAF') || prematches.get('Email Domain').contains('a314u00000NyToqAAF'))      return 'a304u000002pkkgAAA'; //Patch Major Korea 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTorAAF') || prematches.get('Email Domain').contains('a314u00000NyTosAAF'))      return 'a304u000002pkkhAAA'; //Patch Major LATAM 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTotAAF') || prematches.get('Email Domain').contains('a314u00000NyTouAAF'))      return 'a304u000002pkkiAAA'; //Patch Major MA 1 - Named Accounts
    return null;
  }
  private Id matchGroup5(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a314u00000NyTovAAF') || prematches.get('Email Domain').contains('a314u00000NyTowAAF'))      return 'a304u000002pkkjAAA'; //Patch Major MA 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyToxAAF') || prematches.get('Email Domain').contains('a314u00000NyToyAAF'))      return 'a304u000002pkkkAAA'; //Patch Major MA 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTozAAF') || prematches.get('Email Domain').contains('a314u00000NyTp0AAF'))      return 'a304u000002pkklAAA'; //Patch Major MA 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTp1AAF') || prematches.get('Email Domain').contains('a314u00000NyTp2AAF'))      return 'a304u000002pkkmAAA'; //Patch Major MA 5 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTp3AAF') || prematches.get('Email Domain').contains('a314u00000NyTp4AAF'))      return 'a304u000002pkknAAA'; //Patch Major Mexico 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTp5AAF') || prematches.get('Email Domain').contains('a314u00000NyTp6AAF'))      return 'a304u000002pkkoAAA'; //Patch Major Michigan 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTp7AAF') || prematches.get('Email Domain').contains('a314u00000NyTp8AAF'))      return 'a304u000002pkkpAAA'; //Patch Major Michigan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTp9AAF') || prematches.get('Email Domain').contains('a314u00000NyTpAAAV'))      return 'a304u000002pkkqAAA'; //Patch Major Netherlands 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpBAAV') || prematches.get('Email Domain').contains('a314u00000NyTpCAAV'))      return 'a304u000002pkkrAAA'; //Patch Major Netherlands 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NtZCUAA3') || prematches.get('Email Domain').contains('a314u00000NtZCZAA3'))      return 'a304u000002igUnAAI'; //Patch Major Netherlands 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpDAAV') || prematches.get('Email Domain').contains('a314u00000NyTpEAAV'))      return 'a304u000002pkksAAA'; //Patch Major New England 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpFAAV') || prematches.get('Email Domain').contains('a314u00000NyTpGAAV'))      return 'a304u000002pkktAAA'; //Patch Major New England 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpHAAV') || prematches.get('Email Domain').contains('a314u00000NyTpIAAV'))      return 'a304u000002pkkuAAA'; //Patch Major New England 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpJAAV') || prematches.get('Email Domain').contains('a314u00000NyTpKAAV'))      return 'a304u000002pkkvAAA'; //Patch Major New England 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpLAAV') || prematches.get('Email Domain').contains('a314u00000NyTpMAAV'))      return 'a304u000002pkkwAAA'; //Patch Major New England 5 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpNAAV') || prematches.get('Email Domain').contains('a314u00000NyTpOAAV'))      return 'a304u000002pkkxAAA'; //Patch Major New England 6 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpPAAV') || prematches.get('Email Domain').contains('a314u00000NyTpQAAV'))      return 'a304u000002pkkyAAA'; //Patch Major NY/NJ 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpRAAV') || prematches.get('Email Domain').contains('a314u00000NyTpSAAV'))      return 'a304u000002pkkzAAA'; //Patch Major NY/NJ 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpTAAV') || prematches.get('Email Domain').contains('a314u00000NyTpUAAV'))      return 'a304u000002pkl0AAA'; //Patch Major NY/NJ 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpVAAV') || prematches.get('Email Domain').contains('a314u00000NyTpWAAV'))      return 'a304u000002pkl1AAA'; //Patch Major NY/NJ 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpXAAV') || prematches.get('Email Domain').contains('a314u00000NyTpYAAV'))      return 'a304u000002pkl2AAA'; //Patch Major NY/NJ 5 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpZAAV') || prematches.get('Email Domain').contains('a314u00000NyTpaAAF'))      return 'a304u000002pkl3AAA'; //Patch Major NY/NJ 6 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NtZ7PAAV') || prematches.get('Email Domain').contains('a314u00000NtZ7UAAV'))      return 'a304u000002igRPAAY'; //Patch Major NY/NJ 7 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpbAAF') || prematches.get('Email Domain').contains('a314u00000NyTpcAAF'))      return 'a304u000002pkl4AAA'; //Patch Major Ohio 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpdAAF') || prematches.get('Email Domain').contains('a314u00000NyTpeAAF'))      return 'a304u000002pkl5AAA'; //Patch Major Ohio 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpfAAF') || prematches.get('Email Domain').contains('a314u00000NyTpgAAF'))      return 'a304u000002pkl6AAA'; //Patch Major Ohio 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTphAAF') || prematches.get('Email Domain').contains('a314u00000NyTpiAAF'))      return 'a304u000002pkl7AAA'; //Patch Major Pacific 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpjAAF') || prematches.get('Email Domain').contains('a314u00000NyTpkAAF'))      return 'a304u000002pkl8AAA'; //Patch Major Pacific 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTplAAF') || prematches.get('Email Domain').contains('a314u00000NyTpmAAF'))      return 'a304u000002pkl9AAA'; //Patch Major Pacific 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpnAAF') || prematches.get('Email Domain').contains('a314u00000NyTpoAAF'))      return 'a304u000002pklAAAQ'; //Patch Major Pacific 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTppAAF') || prematches.get('Email Domain').contains('a314u00000NyTpqAAF'))      return 'a304u000002pklBAAQ'; //Patch Major Pacific 5 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTprAAF') || prematches.get('Email Domain').contains('a314u00000NyTpsAAF'))      return 'a304u000002pklCAAQ'; //Patch Major PNW 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTptAAF') || prematches.get('Email Domain').contains('a314u00000NyTpuAAF'))      return 'a304u000002pklDAAQ'; //Patch Major PNW 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpvAAF') || prematches.get('Email Domain').contains('a314u00000NyTpwAAF'))      return 'a304u000002pklEAAQ'; //Patch Major Rockies 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTpxAAF') || prematches.get('Email Domain').contains('a314u00000NyTpyAAF'))      return 'a304u000002pklFAAQ'; //Patch Major Southeast 1 - Named Accounts
    return null;
  }
  private Id matchGroup6(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a314u00000NyTpzAAF') || prematches.get('Email Domain').contains('a314u00000NyTq0AAF'))      return 'a304u000002pklGAAQ'; //Patch Major St. Louis 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTq1AAF') || prematches.get('Email Domain').contains('a314u00000NyTq2AAF'))      return 'a304u000002pklHAAQ'; //Patch Major St. Louis 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTq3AAF') || prematches.get('Email Domain').contains('a314u00000NyTq4AAF'))      return 'a304u000002pklIAAQ'; //Patch Major Sweden 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTq5AAF') || prematches.get('Email Domain').contains('a314u00000NyTq6AAF'))      return 'a304u000002pklJAAQ'; //Patch Major Sweden 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTq7AAF') || prematches.get('Email Domain').contains('a314u00000NyTq8AAF'))      return 'a304u000002pklKAAQ'; //Patch Major Sweden 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTq9AAF') || prematches.get('Email Domain').contains('a314u00000NyTqAAAV'))      return 'a304u000002pklLAAQ'; //Patch Major TN 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqBAAV') || prematches.get('Email Domain').contains('a314u00000NyTqCAAV'))      return 'a304u000002pklMAAQ'; //Patch Major TN 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqDAAV') || prematches.get('Email Domain').contains('a314u00000NyTqEAAV'))      return 'a304u000002pklNAAQ'; //Patch Major TOLA 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqFAAV') || prematches.get('Email Domain').contains('a314u00000NyTqGAAV'))      return 'a304u000002pklOAAQ'; //Patch Major TOLA 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqHAAV') || prematches.get('Email Domain').contains('a314u00000NyTqIAAV'))      return 'a304u000002pklPAAQ'; //Patch Major TOLA 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqJAAV') || prematches.get('Email Domain').contains('a314u00000NyTqKAAV'))      return 'a304u000002pklQAAQ'; //Patch Major TOLA 4 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqLAAV') || prematches.get('Email Domain').contains('a314u00000NyTqMAAV'))      return 'a304u000002pklRAAQ'; //Patch Major UK&I 02 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqNAAV') || prematches.get('Email Domain').contains('a314u00000NyTqOAAV'))      return 'a304u000002pklSAAQ'; //Patch Major UK&I 01 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqPAAV') || prematches.get('Email Domain').contains('a314u00000NyTqQAAV'))      return 'a304u000002pklTAAQ'; //Patch Major UK&I 03 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqRAAV') || prematches.get('Email Domain').contains('a314u00000NyTqSAAV'))      return 'a304u000002pklUAAQ'; //Patch Major UK&I 04 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqTAAV') || prematches.get('Email Domain').contains('a314u00000NyTqUAAV'))      return 'a304u000002pklVAAQ'; //Patch Major UK&I 05 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqVAAV') || prematches.get('Email Domain').contains('a314u00000NyTqWAAV'))      return 'a304u000002pklWAAQ'; //Patch Major UK&I 06 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqXAAV') || prematches.get('Email Domain').contains('a314u00000NyTqYAAV'))      return 'a304u000002pklXAAQ'; //Patch Major UK&I 07 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqZAAV') || prematches.get('Email Domain').contains('a314u00000NyTqaAAF'))      return 'a304u000002pklYAAQ'; //Patch Major UK&I 08 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqbAAF') || prematches.get('Email Domain').contains('a314u00000NyTqcAAF'))      return 'a304u000002pklZAAQ'; //Patch Major UK&I 09 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqdAAF') || prematches.get('Email Domain').contains('a314u00000NyTqeAAF'))      return 'a304u000002pklaAAA'; //Patch Major UK&I 10 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqfAAF') || prematches.get('Email Domain').contains('a314u00000NyTqgAAF'))      return 'a304u000002pklbAAA'; //Patch Major1 Japan 1 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqhAAF') || prematches.get('Email Domain').contains('a314u00000NyTqiAAF'))      return 'a304u000002pklcAAA'; //Patch Major1 Japan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqjAAF') || prematches.get('Email Domain').contains('a314u00000NyTqkAAF'))      return 'a304u000002pkldAAA'; //Patch Major1 Japan 3 - Named Accounts
    if(prematches.get('Company Name').contains('a314u00000NyTqlAAF') || prematches.get('Email Domain').contains('a314u00000NyTqmAAF'))      return 'a304u000002pkleAAA'; //Patch Major1 Japan 4 - Named Accounts
    return null;
  }
  //returns the matched patch
  global PatchDataModel.PatchInfo match(PatchDataModel.MatchTarget t)
  {
    Id result = null;
    prematches = prematchList(t);
    result = matchGroup1(t);
    if(result != null) return processResult(result);
    result = matchGroup2(t);
    if(result != null) return processResult(result);
    result = matchGroup3(t);
    if(result != null) return processResult(result);
    result = matchGroup4(t);
    if(result != null) return processResult(result);
    result = matchGroup5(t);
    if(result != null) return processResult(result);
    result = matchGroup6(t);
    if(result != null) return processResult(result);
    return null;
  }
}