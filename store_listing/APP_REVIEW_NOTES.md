# App Review notes — reply to Guideline 2.1

Paste everything inside the block into **App Review Information → Notes**
(limit 4000 characters). Replace the `<…>` parts first.

```
1. SCREEN RECORDING
<link to the screen recording — e.g. a Google Drive / iCloud link set to "anyone with the link can view">
Recorded on <iPhone model>, iOS <version>. It starts at app launch and shows: browsing and search, product page, sign-in with mobile number + OTP, adding to cart, checkout, order tracking, writing a review, reporting a review and blocking its author, and deleting the account (Account > Delete account).

2. PURPOSE AND AUDIENCE
CFO Shop (Call For Orders) is an online marketplace for shoppers in India. Verified local sellers list handloom, fashion, home & kitchen, beauty and electronics products; shoppers browse, compare prices and reviews, order for home delivery, and track, cancel or return orders. It solves the problem of buying from small, trustworthy Indian sellers who have no app of their own, with one cart and checkout across many stores. Audience: adult shoppers in India.

3. HOW TO USE / LOGIN
Browsing, search and product pages need no account.
To sign in: Account tab > Sign in > enter mobile number 9876543210 > Send code > enter code 111173 (no SMS is sent; this demo login works on production).
Main features after sign-in: add to cart > Checkout (address > delivery > payment) > order placed > Orders tab to track, cancel or return. Wishlist (heart icon), Saved addresses (Account), Reviews (product page > Reviews).
User-generated content: product reviews. Each review has a "..." menu with "Report review" (choose a reason; the report goes to our moderation team, who remove objectionable reviews from the admin panel within 24 hours, and the review is hidden for the reporter immediately) and "Block user" (hides all reviews from that author).
Account deletion: Account tab > Delete account (also in Account > Your details). This erases the shopper's personal details, addresses, saved payment methods, wishlist, basket and reviews; order and invoice records are kept for legal reasons. Also available on the web at https://callfororders.in/account/delete

4. EXTERNAL SERVICES
- Our own backend API at https://callfororders.in (catalogue, accounts, orders)
- Razorpay and/or Cashfree payment gateway for UPI, card and net-banking payments of physical goods
- Phone number + one-time code sign-in, issued by our backend
No AI services, analytics or advertising SDKs are used. There are no in-app purchases; the app only sells physical goods delivered to the shopper.

5. REGIONAL DIFFERENCES
The app is offered in India only. Products, prices (INR) and delivery are for Indian addresses; the app behaves the same everywhere it is available.

6. REGULATED INDUSTRY
Not applicable. The app is a retail marketplace for physical goods; payments are processed by RBI-licensed payment gateways (Razorpay / Cashfree). No protected third-party material is used.
```

## Before resubmitting

- [x] Demo login 9876543210 / 111173 works on production (checked 5 Nov)
- [x] `POST /reviews/{id}/report` live; the app uses it
- [x] `DELETE /me` erases personal data (backend 5 Nov)
- [ ] Backend: `php artisan migrate --force` run (review_reports table)
- [ ] Build 1.0.2 (6) uploaded and selected on the version
- [ ] App Review Information → Sign-in: username `9876543210`, password `111173`
- [ ] Screen recording made on a real iPhone and the link pasted above
- [ ] Pricing and Availability → only India (matches point 5)
