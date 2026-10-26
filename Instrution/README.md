# 📦 Vishal's First Warehouse Project: Sales Database (Raw Data Pack)

> **From:** Your Data Manager
> **To:** Vishal Jadhav, Junior Data Engineer (BCA, LPU)
> **Subject:** Your first real warehouse. The data is messy on purpose. Fix it like a professional.

Vishal, here is the brief. The sales team has sent us six raw files from their systems. They are **not clean**. They never are. Your job is to load them, profile them, clean them, join them, and publish numbers the business can trust.

I am **not** giving you the solution. I am giving you the problem, the rules, and the standards. You build the pipeline.

---

## 1. The Mission

Build a **SQL Server data warehouse** using the **Medallion Architecture**:

| Layer | What lives here | Your motto |
|---|---|---|
| 🥉 **Bronze** | Raw data exactly as received | "Never lose anything." |
| 🥈 **Silver** | Cleaned, typed, de-duplicated data | "One version of the truth." |
| 🥇 **Gold** | Reports the business reads | "Numbers my manager can defend." |

Skills you will practise: `TRIM()`, `REPLACE()`, `UPPER()`, `LOWER()`, `NULLIF()`, `COALESCE()`, `TRY_CONVERT()`, `CASE`, `GROUP BY`, `HAVING`, `ROW_NUMBER()`, `LEFT JOIN`.

---

## 2. Warehouse Scope: The Date Range 📅

This is what is **in scope** for the warehouse. Anything outside these ranges (or any date that is not a real calendar date) is **not trusted**. It does not go into Silver. It goes to quarantine (see Section 9).

| Table | Column | In-scope range |
|---|---|---|
| orders | `order_date` | **2024-01-01 → 2025-12-31** (two full years) |
| customers | `signup_date` | **2022-01-01 → 2025-06-30** |
| payments | `payment_date` | **2024-01-01 → 2026-01-05** (payment can land up to 5 days after the order) |

**Reporting window for Gold:** January 2024 to December 2025, 24 months.

Business rule: a customer should not order before they signed up. That is a bonus check for you.

---

## 3. Folder Structure

```text
Vishals_First_Warehouse_Project/
└── dataset/
    ├── README.md          <- you are here
    ├── locations.csv
    ├── customers.csv
    ├── products.csv
    ├── orders.csv
    ├── order_lines.csv
    └── payments.csv
```

---

## 4. The Six Files

Row counts below are for the **raw files** (header excluded), and they **include** the duplicate and junk rows. After cleaning, expect fewer.

| File | Role | Raw rows | Purpose |
|---|---|---|---|
| `locations.csv` | 🏛️ Master / reference | 28 | Localities, cities, states and regions. Kept separate from customers on purpose, so you practise joins. |
| `customers.csv` | 🏛️ Master | 2,557 | Who is buying. |
| `products.csv` | 🏛️ Master | 83 | What we sell. |
| `orders.csv` | 💳 Transaction (header) | 2,538 | One row per order: who, when, status, channel. |
| `order_lines.csv` | 💳 Transaction (detail) | 4,056 | One row per product in an order: quantity, price, discount. |
| `payments.csv` | 💳 Transaction | 2,361 | How and when each order was paid. |

### Master tables vs transaction tables

- **Master / reference tables** describe *things* (places, people, products). They change slowly. A customer exists whether or not they ever order. Each row should be unique by its ID.
- **Transaction tables** record *events* (an order was placed, a line was added, a payment was made). They grow every day and reference the master tables through foreign keys.

Why `order_lines` is separate from `orders`: one order can contain many products. Quantity, price and discount belong to the **line**, not the order. This is the classic header/detail design. You will have to join them to calculate revenue.

---

## 5. Data Dictionary and Suggested SQL Server Data Types

**Bronze rule:** because the raw data contains junk (like `N/A` in a price column), load **every column as `NVARCHAR(255)`** into Bronze, or the load will fail or silently change your data. The "Silver type" column is the type you convert **to** after cleaning.

### 5.1 locations

| Column | Meaning | Silver type | Notes |
|---|---|---|---|
| `location_id` | Location identifier | `INT` | Primary key candidate |
| `locality` | Neighbourhood or area | `NVARCHAR(100)` | The same locality name can exist in different cities |
| `city` | City | `NVARCHAR(100)` | |
| `state` | State or union territory | `NVARCHAR(100)` | |
| `region` | North / South / East / West | `NVARCHAR(20)` | |

### 5.2 customers

| Column | Meaning | Silver type | Notes |
|---|---|---|---|
| `customer_id` | Customer identifier | `INT` | Primary key candidate |
| `customer_name` | Full name | `NVARCHAR(150)` | |
| `email` | Email address | `NVARCHAR(255)` | Should be stored lowercase |
| `phone` | Phone number | `VARCHAR(20)` | Keep as text, not a number. Leading `+`, spaces and dashes exist |
| `location_id` | Where the customer lives | `INT` | FK to `locations` |
| `signup_date` | Date the customer joined | `DATE` | |

### 5.3 products

| Column | Meaning | Silver type | Notes |
|---|---|---|---|
| `product_id` | Product identifier | `INT` | Primary key candidate |
| `product_name` | Product name | `NVARCHAR(150)` | |
| `category` | Product category | `NVARCHAR(100)` | Should end up as a small, fixed list |
| `brand` | Brand | `NVARCHAR(100)` | |
| `list_price` | Official price in INR | `DECIMAL(10,2)` | |
| `active_flag` | Is the product still sold? | `BIT` | Final values: 1 = active, 0 = inactive |

### 5.4 orders

| Column | Meaning | Silver type | Notes |
|---|---|---|---|
| `order_id` | Order identifier | `INT` | Primary key candidate |
| `order_date` | Date the order was placed | `DATE` | See Section 2 |
| `customer_id` | Who placed it | `INT` | FK to `customers` |
| `order_status` | Lifecycle status | `NVARCHAR(20)` | Final list: Completed, Shipped, Pending, Cancelled, Returned |
| `sales_channel` | Where it was sold | `NVARCHAR(30)` | Final list: Online, Mobile App, Store, Marketplace |

### 5.5 order_lines

| Column | Meaning | Silver type | Notes |
|---|---|---|---|
| `order_line_id` | Line identifier | `INT` | Primary key candidate |
| `order_id` | Parent order | `INT` | FK to `orders` |
| `product_id` | Product sold | `INT` | FK to `products` |
| `quantity` | Units sold | `INT` | Zero quantity needs investigation |
| `unit_price` | Price per unit actually charged, INR | `DECIMAL(10,2)` | May differ from `list_price` |
| `discount_pct` | Discount as a whole-number percentage (`10` means 10%) | `DECIMAL(5,2)` | |

### 5.6 payments

| Column | Meaning | Silver type | Notes |
|---|---|---|---|
| `payment_id` | Payment identifier | `INT` | Primary key candidate |
| `order_id` | Order being paid | `INT` | FK to `orders`. An order can have more than one payment attempt |
| `payment_method` | How they paid | `NVARCHAR(30)` | Final list: UPI, Credit Card, Debit Card, Net Banking, Cash on Delivery |
| `payment_status` | Payment outcome | `NVARCHAR(20)` | Final list: Paid, Failed, Refunded, Pending |
| `payment_date` | Date of payment | `DATE` | See Section 2 |
| `payment_reference` | Gateway reference code | `NVARCHAR(30)` | Not every payment has one (for example, cash on delivery) |

---

## 6. Keys and Relationships

### Primary key candidates

`location_id`, `customer_id`, `product_id`, `order_id`, `order_line_id`, `payment_id`.

I said **candidates**. In the raw files these are **not guaranteed unique or non-NULL**. Proving that is part of your job.

### Intended foreign keys

| Child column | → | Parent column | Join type to use for checking |
|---|---|---|---|
| `customers.location_id` | → | `locations.location_id` | `LEFT JOIN` |
| `orders.customer_id` | → | `customers.customer_id` | `LEFT JOIN` |
| `order_lines.order_id` | → | `orders.order_id` | `LEFT JOIN` |
| `order_lines.product_id` | → | `products.product_id` | `LEFT JOIN` |
| `payments.order_id` | → | `orders.order_id` | `LEFT JOIN` |

```text
locations ──< customers ──< orders ──< order_lines >── products
                              │
                              └──< payments
```

⚠️ **Warning:** the raw data may break these relationships. Some children point to parents that do not exist. To find orphans, `LEFT JOIN` child to parent and look for parent rows that come back `NULL`.

---

## 7. What Is Wrong With the Data (Categories Only)

I am not telling you which rows. You will find them with profiling queries. Hunt for these categories across the tables:

| # | Category | What to look for |
|---|---|---|
| 1 | **Duplicates** | Identical rows, the same ID appearing more than once, and the same real-world transaction recorded twice under different IDs |
| 2 | **NULLs and blanks** | Real `NULL`, empty strings `''`, strings that only contain spaces, and the *text* `'NULL'` |
| 3 | **Whitespace** | Leading and trailing spaces in names and categories |
| 4 | **Inconsistent casing** | `UPI`, `upi`, `Upi` |
| 5 | **Inconsistent labels** | Different spellings of the same category, payment method, status or flag |
| 6 | **Invalid dates** | Dates that do not exist, text in date columns, wrong formats |
| 7 | **Non-numeric numbers** | Text in price, quantity or discount columns, currency symbols, commas, percent signs |
| 8 | **Zero quantities** | Lines that say 0 units were sold |
| 9 | **Broken relationships** | Missing or invalid foreign-key values |
| 10 | **Missing primary keys** | Rows with no ID at all |
| 11 | **Duplicated transactions** | Same business event recorded twice |

---

## 8. Manager's Golden Rules ⚖️

1. **Never edit or delete Bronze.** Bronze is the evidence. If you break it, you cannot prove what the source sent.
2. **Never silently drop rows.** Every removed row must be logged with a reason.
3. **Reconcile every layer.** `Bronze rows = Silver rows + Quarantined rows`. If it does not add up, something vanished, and that is your bug.
4. **Standardise before you compare.** Trim and fix casing first, otherwise `'UPI'` and `'upi '` look like different values.
5. **Profile first, clean second.** Count the problem before you fix it.
6. **Document your decisions.** If you pick one duplicate over another, write down why.
7. **Revenue errors are the costliest.** Double-counted orders and bad prices hurt more than a missing email.

---

## 9. 🛠️ The Cleaning Playbook: "What Should I Do If…?"

### 9.1 I found duplicates. What now?

First, work out **which kind** of duplicate it is. Each kind has a different answer.

| Type | How it looks | What to do |
|---|---|---|
| **A. Exact duplicate** | Every column is identical | Safe to remove. Keep **one** row. |
| **B. Same ID, different values** | `customer_id` repeats but the email or name differs | Do **not** blindly delete. Decide which version wins (see below). Keep one, quarantine the other. |
| **C. Different ID, same real-world event** | Two `order_lines` with different line IDs but the same order, product and quantity | Likely a duplicated transaction. Investigate. If it is a true duplicate, keep one. Otherwise you **double-count revenue**. |

**How to pick the winner for Type B** (decision order):

1. The row with the **most complete data** (fewest NULLs or blanks).
2. The row that looks **latest or most final** (for example, a `Paid` payment beats a `Pending` one; a `Completed` order beats a `Pending` one).
3. If still tied, the **first one loaded**. This is why I want you to add a load-order column (an `IDENTITY` column or row number) to your Bronze tables. Without it, "first" has no meaning.

**The tool:** `ROW_NUMBER() OVER (PARTITION BY <the key> ORDER BY <your winner rule>)`. Keep row number 1. Everything else goes to quarantine with the reason `DUPLICATE`.

**Profiling pattern:** `GROUP BY <key> HAVING COUNT(*) > 1`.

> **Rule of thumb:** Bronze keeps everything. Silver keeps one. Quarantine keeps the evidence.

### 9.2 The ID is NULL or blank. Keep it or not?

It depends **which** ID.

**A. The primary key itself is NULL or blank** (for example, `customer_id` is empty on the customer row).
👉 **Do not load it into Silver. Quarantine it** with the reason `MISSING_PRIMARY_KEY`.
Why: a row with no ID cannot be identified, cannot be joined, and cannot be de-duplicated. **Never invent an ID** to make it fit. Log how many you quarantined and tell the data owner.

**B. A foreign key is NULL or invalid** (for example, `orders.customer_id` is empty, or points to a customer that does not exist).
👉 It depends on the table:

| Situation | Decision |
|---|---|
| Order with a missing or unknown customer | **Keep it.** Real money was spent. Flag it, and in reports show it as `'Unknown'`. |
| Customer with a missing or unknown location | **Keep it.** Show location as `'Unknown'`. |
| `order_lines` pointing to an order that does not exist | **Quarantine.** With no parent order there is no date, no customer and no status. |
| `order_lines` with a missing or invalid product | **Quarantine** for now (or keep with an `'Unknown product'` flag if you can justify it). Write your decision down. |
| `payments` pointing to an order that does not exist | **Quarantine** with the reason `ORPHAN_PAYMENT`. |

**C. A normal descriptive column is NULL** (email, phone, brand…).
👉 **Keep the row.** Turn blanks into real `NULL`s with `NULLIF`. Only replace `NULL` with `'Unknown'` using `COALESCE` in **Gold** (for display), not in Silver.

### 9.3 Quick decision table for everything else

| Problem | Decision |
|---|---|
| Spaces around text | `TRIM()` it. Always. |
| Mixed casing | Pick one standard (`LOWER` for emails, a proper label list for categories) and apply it. |
| Many spellings of one label | Map them to **one** official value with `CASE`. Anything you cannot map goes to `'Unknown'` and you review it. |
| Active flag has `Y`, `Yes`, `TRUE`, `1`… | Map every value to `1` or `0`. If you cannot decide, leave `NULL` and flag it. |
| Invalid date | `TRY_CONVERT(DATE, …)` returns `NULL` for bad dates. For `order_date`, a row with no valid date cannot be used for monthly sales, so **quarantine it**. For `signup_date`, keep the row with a `NULL` date. |
| Date outside the Section 2 range | Quarantine with the reason `OUT_OF_RANGE`. |
| Price is text (`N/A`, `Rs.499`, `1,299`) | Strip the junk with `REPLACE()`, then `TRY_CONVERT(DECIMAL(10,2), …)`. If it still fails, set it to `NULL`. For `unit_price` you may fall back to the product's `list_price`, but **document it**. |
| Discount is `10%`, blank or text | Strip the `%`, convert, and treat true blanks as `0`, **only if** you decide that is a valid business assumption. Write it down. |
| Quantity is `0` | **Investigate before deciding.** Check the parent order's status. A zero on a cancelled order may be legitimate. Otherwise it is a data error. Either way, flag it and **exclude it from sales metrics**. Do not just delete it. |
| Quantity is blank | Cannot calculate revenue, so quarantine. |
| Order has several payment rows | Normal. A failed attempt followed by a successful one is real life. Decide which payment represents the order (usually the `Paid` one). |

### 9.4 Your function cheat-sheet 🧰

| Function | Use it for | Tiny example |
|---|---|---|
| `TRIM(x)` | Remove leading/trailing spaces | `TRIM(' Priya ')` → `Priya` |
| `UPPER(x)` / `LOWER(x)` | Standardise case | `LOWER(email)` |
| `REPLACE(x, old, new)` | Remove or swap junk characters | `REPLACE(price, ',', '')` |
| `NULLIF(x, '')` | Turn a blank into a real `NULL` | `NULLIF(TRIM(phone), '')` |
| `COALESCE(x, y)` | Fill a `NULL` with a fallback | `COALESCE(city, 'Unknown')` |
| `TRY_CONVERT(type, x)` | Convert safely. Returns `NULL` instead of an error | `TRY_CONVERT(DATE, order_date)` |
| `CASE WHEN …` | Map many values to one | `CASE WHEN x IN ('Y','Yes') THEN 1 …` |
| `GROUP BY` + `HAVING` | Find duplicate keys and summarise | `HAVING COUNT(*) > 1` |
| `ROW_NUMBER() OVER (…)` | Rank duplicates, keep the first | `PARTITION BY id ORDER BY …` |
| `LEFT JOIN` | Find orphans and combine tables | child `LEFT JOIN` parent, look for parent `NULL` |

**Order matters:** `TRIM` → `NULLIF` → `REPLACE` → `TRY_CONVERT` → `CASE` / standardise → `COALESCE` (only in Gold).
Example of why: the text `'NULL'` and `' '` are **not** real `NULL`s. If you do not `TRIM` and `NULLIF` them first, your `COALESCE` will never fire.

---

## 10. Your Workflow: Step by Step 🚶

### Step 1: 🥉 Bronze: load it raw
- Create a database and a `bronze` schema.
- Create one table per CSV with **all columns `NVARCHAR(255)`**, plus a load-order column.
- Import using `BULK INSERT` or the SSMS Import Flat File wizard.
- Files are **UTF-8**. Use `CODEPAGE = '65001'` and `FORMAT = 'CSV'`, with `FIRSTROW = 2` to skip the header.
- ✅ **Checkpoint:** Bronze row count = the raw count in Section 4 for every table.

### Step 2: 🔍 Profile: understand before you touch
For every table, write down the answers to:
- How many rows? How many **distinct** IDs?
- Which IDs are duplicated? Which are `NULL` or blank?
- Which text columns have leading/trailing spaces? (Compare `LEN(col)` with `LEN(TRIM(col))`.)
- What distinct values exist in each label column (`category`, `payment_method`, `order_status`…)? Use `GROUP BY` and count.
- Which dates and numbers fail `TRY_CONVERT`?
- Are there orphans for every relationship in Section 6?
- Any quantity of `0`?

Keep a **profiling log**. Managers love evidence.

### Step 3: 🥈 Silver: clean it
- Apply the Section 9 playbook table by table.
- Convert to the proper data types.
- Remove duplicates using `ROW_NUMBER()`.
- Send rejected rows to **quarantine tables** with a `reject_reason` column.
- Add foreign-key checks.
- ✅ **Checkpoint:** `Bronze = Silver + Quarantine` for every table.

**Suggested cleaning order:** `locations` → `customers` → `products` → `orders` → `order_lines` → `payments`. Parents first, children last. That way you can check children against *clean* parents.

### Step 4: 🔗 Integrate
- Join `orders` → `customers` → `locations` to get who and where.
- Join `orders` → `order_lines` → `products` to get what.
- Join `orders` → `payments` to get how it was paid.
- Watch out for **row multiplication**: joining orders to payments when an order has two payments can duplicate your order and inflate revenue. Check your row counts after every join.

### Step 5: 🥇 Gold: reports the business wants
Build a few simple **views**:

1. **Monthly sales:** revenue and order count per month (Jan 2024 → Dec 2025).
2. **Sales by product category:** revenue and units per category.
3. **Sales by city:** revenue and customers per city (and region if you like).

**Revenue formula (use this everywhere):**

```text
line_revenue = quantity × unit_price × (1 − discount_pct / 100)
```

**Which orders count as sales?** My rule: only `Completed` and `Shipped` orders count as revenue. `Cancelled` and `Pending` are excluded. `Returned` should be shown separately. If you disagree, write down why and tell me.

Bonus views if you are feeling strong: top 10 products, payment method mix, sales by channel.

---

## 11. Definition of Done ✅

- [ ] All six CSVs are loaded into Bronze with matching row counts
- [ ] A profiling log exists for every table
- [ ] Silver has proper data types, with no duplicate primary keys
- [ ] A quarantine table exists with a reject reason for every removed row
- [ ] `Bronze = Silver + Quarantine` for every table
- [ ] All labels standardised to the final lists in Section 5
- [ ] All dates in the Section 2 range
- [ ] Three Gold views built and sanity-checked (do the totals match a manual calculation?)
- [ ] Every decision (duplicates, NULL IDs, zero quantities, price fallbacks) is documented

---

## 12. File Notes

- Encoding: **UTF-8**, comma-separated, first row is the header, fields containing commas are quoted.
- Data is synthetic and generated with a fixed random seed, so it is reproducible. No real people or businesses are involved.
- All amounts are in Indian Rupees (INR).
- The raw files open fine in Excel. **Do not save them from Excel** after opening, because it may reformat dates and phone numbers and destroy the evidence.

Good luck, Vishal. Make me proud. 🚀
