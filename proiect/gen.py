insert_stm = """\
INSERT ALL
{}
SELECT * FROM dual;
"""

into_stm = """\
INTO {} ({}) VALUES ({})\
"""

from random import choice, randint, shuffle
from lorem.text import TextLorem
from itertools import product
from string import ascii_uppercase

def values_to_string(l):
    args = []
    for i in l:
        if type(i) is int:
            args.append(str(i))
        elif type(i) is bool:
            args.append('1' if i else '0')
        elif type(i) is str:
            args.append("\'{}\'".format(i))

    return ', '.join(args)

def into(table, columns, args):
    return into_stm.format(table, ', '.join(columns), values_to_string(args))

def insert(table, columns, values):
    s = []
    for v in values:
        s.append(into(table, columns, v))

    return insert_stm.format('\n'.join(s))

def random_name(n = 4):
    lorem = TextLorem(wsep=' ', srange=(2,n))
    return lorem.sentence()[:-1].upper()

dollar_to_cents = 100

# holders - accounts - tickers - owns
def gen_hato(n, m):
    holders_values = [[
            ''.join([str(randint(0, 9)) for _ in range(9)]),
            random_name(),
            choice(['PERSON', 'COMPANY']),
            random_name(6),
            random_name(6),
            'company{}@email.com'.format(i),
            '+99-222-{}'.format(i),
        ] for i in range(n)]
    holders_values.append([
        '123456789',
        'FAKE STOCK EXCHANGE LTD.',
        'COMPANY',
        'MARIUS LACATUS NO. 7',
        'STEPHAN THE GREAT NO 1453',
        'michaeljackson@obama.gov',
        '07222222'
        ])
    stock_exchange_id = len(holders_values)

    ticker_names = list(product(ascii_uppercase, repeat = 3))
    shuffle(ticker_names)
    tickers_values = [[
            ''.join(ticker_names.pop()),
            randint(10**3, 10**7),
            randint(1, 200) * dollar_to_cents,
        ] for i in range(m)]

    owns = [[
            stock_exchange_id,
            tickers_values[i][0],
            0,
        ] for i in range(m)]

    asks = [[
            'ASK',
            tickers_values[i][0],
            stock_exchange_id,
            tickers_values[i][1],
            tickers_values[i][2],
        ] for i in range(m)]

    s = [
            insert('holder', [
            'legal_id',
            'legal_name',
            'legal_status',
            'physical_address',
            'billing_address',
            'email',
            'phone',
        ] , holders_values),

            insert('account', ['holder_id', 'capital'], [[holders_values[i][0], randint(10**3, 10**7) * dollar_to_cents] for i in range(n + 1)]),

            insert('ticker', ['name', 'total_shares', 'last_price'], tickers_values),

            insert('own', ['account_id', 'ticker_name', 'amount'], owns),

            insert('quotation', ['type', 'ticker_name', 'account_id', 'amount', 'price'], asks)
        ]

    return '\n\n'.join(s)

print (gen_hato(5, 10))