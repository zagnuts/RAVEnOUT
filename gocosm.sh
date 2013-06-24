i=1
for (( ; ; ))
do
 sleep $i
 python cosm.py
 date >>  cosmoops.log
done
