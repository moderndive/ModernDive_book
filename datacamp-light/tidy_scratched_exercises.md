<!--
 **`paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How many variables are presented in the table below?  What does each row correspond to, or in other words, what are the observational units? (**Hint:** You may not be able to answer both of these questions immediately but take your best guess.)


```{r echo=FALSE, message=FALSE}
#library(dplyr)
#library(knitr)
#students <- c(4, 6)
#faculty <- c(2, 3)
#kable(data_frame("students" = students, "faculty" = faculty))
```

 **`paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** The confusion you may have encountered in `paste0("(LC", chap, ".", (lc - 1), ")")` is a common one those that work with data are commonly presented with.  This dataset is not tidy.  Actually, the dataset in `paste0("(LC", chap, ".", (lc - 1), ")")` has three variables not the two that were presented.  Make a guess as to what these variables are and present a tidy dataset instead of this untidy one given in `paste0("(LC", chap, ".", (lc - 1), ")")`.

 **`paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** The actual data presented in LC`paste0("(LC", chap, ".", (lc - 2), ")")` is given below in tidy data format:

```{r echo=FALSE, message=FALSE, warning=FALSE}
#library(dplyr)
#role <- c(rep("student", 10), rep("faculty", 5))
#sociology <- c(rep(TRUE, 4), rep(FALSE, 6), rep(TRUE, 2), rep(FALSE, 3))
#school_type <- c(rep("Public", 6), rep("Private", 4), rep("Public", 3), rep("Private", 2))
#kable(data_frame("role" = role, `Sociology?` = sociology,
#  `Type of School` = school_type))
```

#- What does each row correspond to?  
#- What are the different variables in this data frame?  
#- The `Sociology?` variable is known as a logical variable.  What types of values does a logical variable take on?



**`r paste0("(LC", chap, ".", (lc - 3), ")")`** There are 2 variables below, but what does each row correspond to? We don't know because there are no identification variables.  
```

```{r}
students <- c(4, 6)
faculty <- c(2, 3)
data_frame("students" = students, "faculty" = faculty) %>% 
  kable()
```

```{asis, include=show_solutions('3-3')}
**`r paste0("(LC", chap, ".", (lc - 2), ")")`** We need at least a third variable to identify the observations. For example a variable "Department".

**`r paste0("(LC", chap, ".", (lc - 1), ")")`** Sociology example
 
* Each row is a member of a university.
* Variables are the columns
* `TRUE` and `FALSE`. This is called a logical variable AKA a boolean variable. `1` and `0` can also be used
```
