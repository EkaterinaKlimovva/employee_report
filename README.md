# employee_report
According to the Employees, Jobs and Job_History tables, get a report for all employees in the form:
The number is in order. Employee <Last Name> 
hired <Start date>,
worked in the position <Position> from <Start date> <Number> of days to <End date>,
then <Transition date> moved to the position <New position>  and worked <Number> of days until <End date>, 
then ......
Example:
1. Employee Jennifer Whalen
was hired on
17.09.87, worked as an Administration Assistant from 17.09.87 2100 days to 25.05.94, 
then he was not listed in positions for 36 days,
then on 01.07.94 he moved to the position of Public Accountant and worked for 1644 days until 12.01.14
2. Employee Neena Kochhar 
he was hired on
21.09.89, worked as a Public Accountant from 21.09.89 1497 days to 27.10.93,
then moved to the position of Accounting Manager on 28.10.93 and worked 1234 days on 12.01.14
...........
A total of 107 entries
Notes:
 Provide for the use of an index table.
 Provide an appropriate ending in the word "days" for different numbers.
 When calculating the number of days, the time components are not taken into account.
 The list must also include employees whose position has remained unchanged since they entered the job.
 If there is no information about some transitions in the table, then the corresponding entry should be displayed ("then <Number of days> was not listed in positions").
 The last line for each employee should display information about the number of days that he worked in the last position in the format: ...worked in the position from <Start date of work in the position> to <Current date>.
