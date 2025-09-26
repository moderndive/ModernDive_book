**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why was it important to mix the bowl before we sampled the balls?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is it that our 33 groups of friends did not all have the same numbers of balls that were red out of 50, and hence different proportions red?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why couldn't we study the effects of sampling variation when we used the virtual shovel only once? Why did we need to take more than one virtual sample (in our case 33 virtual samples)?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why did we not take 1000 "tactile" samples of 50 balls by hand?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Looking at Figure \@ref(fig:samplingdistribution-virtual-1000), would you say that sampling 50 balls where 30% of them were red is likely or not? What about sampling 50 balls where 10% of them were red?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In Figure \@ref(fig:comparing-sampling-distributions), we used shovels to take 1000 samples each, computed the resulting 1000 proportions of the shovel's balls that were red, and then visualized the distribution of these 1000 proportions in a histogram. We did this for shovels with 25, 50, and 100 slots in them. As the size of the shovels increased, the histograms got narrower. In other words, as the size of the shovels increased from 25 to 50 to 100, did the 1000 proportions - A. vary less, - B. vary by the same amount, or - C. vary more?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What summary statistic did we use to quantify how much the 1000 proportions red varied? - A. The interquartile range - B. The standard deviation - C. The range: the largest value minus the smallest.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In the case of our bowl activity, what is the *population parameter*? Do we know its value?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What would performing a census in our bowl activity correspond to? Why did we not perform a census?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What purpose do *point estimates* serve in general? What is the name of the point estimate specific to our bowl activity? What is its mathematical notation?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How did we ensure that our tactile samples using the shovel were random?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is it important that sampling be done *at random*?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are we *inferring* about the bowl based on the samples using the shovel?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What purpose did the *sampling distributions* serve?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does the *standard error* of the sample proportion $\widehat{p}$ quantify?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** The table that follows is a version of Table \@ref(tab:comparing-n-2) matching sample sizes $n$ to different *standard errors* of the sample proportion $\widehat{p}$, but with the rows randomly re-ordered and the sample sizes removed. Fill in the table by matching the correct sample sizes to the correct standard errors. set.seed(76) comparing_n_table <- virtual_prop %>% group_by(n) %>% summarize(sd = sd(prop_red)) %>% mutate( n = str_c("n = ") ) %>% rename(`Sample size` = n, `Standard error of $\\widehat{p}$` = sd) %>% sample_frac(1) comparing_n_table %>% kbl( digits = 3, caption = "Standard errors of $\\widehat{p}$ based on n = 25, 50, 100", booktabs = TRUE, escape = FALSE, linesep = "" ) %>% kable_styling( font_size = ifelse(is_latex_output(), 10, 16), latex_options = c("hold_position") ) For the following four *Learning checks*, let the *estimate* be the sample proportion $\widehat{p}$: the proportion of a shovel's balls that were red. It estimates the population proportion $p$: the proportion of the bowl's balls that were red.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the difference between an *accurate* and a *precise* estimate?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How do we ensure that an estimate is *accurate*? How do we ensure that an estimate is *precise*?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In a real-life situation, we would not take 1000 different samples to infer about a population, but rather only one. Then, what was the purpose of our exercises where we took 1000 different samples?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Figure \@ref(fig:accuracy-vs-precision) with the targets shows four combinations of "accurate versus precise" estimates. Draw four corresponding *sampling distributions* of the sample proportion $\widehat{p}$, like the one in the leftmost plot in Figure \@ref(fig:comparing-sampling-distributions-3).

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** The Royal Air Force wants to study how resistant all their airplanes are to bullets. They study the bullet holes on all the airplanes on the tarmac after an air battle against the Luftwaffe (German Air Force).

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Imagine it is 1993, a time when almost all households had landlines. You want to know the average number of people in each household in your city. You randomly pick out 500 phone numbers from the phone book and conduct a phone survey.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** You want to know the prevalence of illegal downloading of TV shows among students at a local college. You get the emails of 100 randomly chosen students and ask them, "How many times did you download a pirated TV show last week?".

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** A local college administrator wants to know the average income of all graduates in the last 10 years. So they get the records of five randomly chosen graduates, contact them, and obtain their answers.

**Solution**:


