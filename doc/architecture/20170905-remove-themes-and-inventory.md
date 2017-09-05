## Problem 

1. We are no longer using "Themes" as the grouping mechanism that drives content transformation. We rely on organisations.
2. The "Inventory tool" is no longer in use. 
3. The code for the "Inventory tool" is a developer exercise that was merged into production because we thought that we needed that functionality to model the input of an audit. The current status of the code for the "Inventory tool" is not good, and has been identified many times as "tech debt". 
4. We have found out that the output of this tool is not fit for purpose, and that is has accuracy problems.  
  
## Decision

1. Remove Theme filtering from Auditing Tool.
2. Remove the "Inventory Tool"

In case we need to build an inventory tool, we can always rely on Git.
