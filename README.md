
# Installation #

Put this script in location where you want to start saving your tokens.
Open this script with vim and change my_token and infura_api_key (e.g. cbee44663ab949e5b301b44da6069380).

Now let's test that it works:

```
python3 -m pip install web3
python3 ./keep.py
```

You should now see the file in the same directory, e.g. Eternal Harmony.2022-12-19.html

Let's now add this script to cron to run it every 3 days.

Run `crontab -e` and add the following line:

```
0 0 * * *  bash -c '(( $(date +\%s) / 86400 \% 3 == 0 )) && cd <your script folder> && python3 ./keep.py'
```

