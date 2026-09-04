# Backend / API Gaps For Exact Customer App UI

This file lists the data that the Flutter customer app needs from backend to avoid static UI and to match `customer-app 1.html` screens more closely.

## Product Listing Filters

Current frontend sends these query params to `GET /products`:

- `q`
- `category_id`
- `vendor_id`
- `brand`
- `min_price`
- `max_price`
- `min_rating`
- `min_discount`
- `assured`
- `cod`
- `in_stock`
- `sort`
- `page`
- `per_page`

Missing backend support / metadata:

1. `GET /products/filters` or `facets` object inside `GET /products`
   - Frontend should not hardcode filter chips.
   - Required response:
     - `price_ranges[]`: `{ "label": "Under ₹1,000", "max_price": 1000 }`
     - `rating_ranges[]`: `{ "label": "4 ★ & above", "min_rating": 4 }`
     - `discount_ranges[]`: `{ "label": "30% or more", "min_discount": 30 }`
     - `sellers[]`: `{ "id": 1, "name": "Meera Textiles", "count": 12 }`
     - `brands[]`: `{ "name": "Meera Looms", "count": 8 }`
     - `boolean_filters[]`: `assured`, `cod`, `in_stock`

2. Product counts per filter
   - Filter sheet should show only valid seller/brand/range choices for the current category/search.
   - Backend should return counts with each facet option.

3. Confirm filter param support
   - `assured=1`
   - `cod=1`
   - `in_stock=1`
   - `vendor_id`
   - `brand`
   - `min_discount`
   - These are now wired from Flutter, but backend must actually apply them.

4. Sort values
   - Frontend now sends backend doc values:
     - `relevance`
     - `price_low`
     - `price_high`
     - `rating`
     - `discount`
     - `newest`
   - Backend should reject unknown sort values with 422 and return a clear message.

5. Product card fields required in every `GET /products` item
   - `id`
   - `slug`
   - `name`
   - `brand`
   - `image`
   - `price`
   - `mrp`
   - `discount_percent`
   - `rating`
   - `ratings_count`
   - `in_stock`
   - `assured`
   - `vendor`: `{ "id": 1, "name": "Meera Textiles" }`
   - `is_wishlisted` when authenticated

6. Empty/result count metadata
   - `GET /products` should return Laravel pagination metadata consistently.
   - Needed fields:
     - `total`
     - `per_page`
     - `current_page`
     - `last_page`

## Home Screen

Missing backend support:

1. `banners[]` in `GET /home`
   - Hardcoded Flutter banners were removed.
   - Required fields:
     - `id`
     - `title`
     - `subtitle`
     - `image_url`
     - `deeplink_route`
     - `deeplink_params`
     - `sort_order`
     - `active`

2. Account/wishlist/cart badges should be accurate
   - Either expose counts in `GET /home`, or keep existing separate count APIs reliable.

## Account Summary

The Account screen should not hardcode counts.

Needed endpoint:

- `GET /me/summary`

Required fields:

- `orders_count`
- `orders_spent`
- `wishlist_count`
- `coupon_count`
- `reviews_written_count`
- `reviews_pending_count`
- `addresses_count`
- `devices_count`

## Payment Methods

The Payments screen currently cannot be fully wired because saved payment APIs are missing.

Needed endpoints:

- `GET /payment-methods`
- `POST /payment-methods`
- `DELETE /payment-methods/{id}`
- `PATCH /payment-methods/{id}/default`

Required fields:

- `id`
- `type`: `card`, `upi`, `wallet`
- `label`
- `masked_value`
- `provider`
- `verified`
- `expires_at`
- `is_default`

## Store Credit / Wallet

Needed endpoint:

- `GET /wallet`

Required fields:

- `balance`
- `currency`
- `source`
- `expires_at`
- `transactions[]`

## Orders / Buy Again

Frontend calls:

- `POST /orders/{number}/reorder`

Backend response should include:

- `added[]`
- `skipped[]`
- updated cart summary or `cart_count`

Each skipped item should include:

- `product_id`
- `variant_id`
- `reason`: `out_of_stock`, `variant_missing`, `inactive_product`, `price_changed`
- `message`

## Order Invoice

The order detail screen has invoice action, but there is no API.

Needed endpoint:

- `GET /orders/{number}/invoice`

Return one of:

- PDF file response
- signed `invoice_url`
- email status if invoice is only emailed

## Track Order

For exact track-order UI, `GET /orders/{number}/track` should include:

- `carrier`
- `tracking_number`
- `tracking_url`
- `support_phone`
- `eta_label`
- `events[]`

Each event:

- `label`
- `description`
- `location`
- `happened_at`
- `state`: `done`, `current`, `pending`

## Cancellation / Return Details

Current request detail UI needs exact timeline fields.

Needed in `GET /requests/{number}`:

- `events[]`

Each event:

- `label`
- `status`
- `happened_at`
- `scheduled_at`
- `state`: `done`, `current`, `pending`

Or explicit fields:

- `seller_approved_at`
- `picked_up_at`
- `refund_issued_at`
- `cancelled_at`
- `withdrawn_at`

## Support / Help Centre

Help actions are placeholders until backend returns support config.

Needed endpoint:

- `GET /support/config`

Required fields:

- `chat_enabled`
- `chat_provider`
- `chat_session_url` or `chat_token`
- `phone`
- `hours`
- `faq[]`

Each FAQ:

- `question`
- `answer`
- `sort_order`

## Legal Pages

Needed endpoints:

- `GET /legal/terms`
- `GET /legal/privacy`
- `GET /legal/returns`
- `GET /legal/licenses`
- `GET /legal/grievance-officer`

Each should return:

- `title`
- `body`
- `updated_at`

## Account Deletion

Needed endpoint:

- `DELETE /me`

or:

- `POST /me/delete-request`

Required behavior:

- return clear status/message
- revoke auth token after successful deletion request if account is immediately disabled

## Notification Settings

Only marketing email is currently updateable through profile.

Needed endpoints:

- `GET /notification-preferences`
- `PUT /notification-preferences`

Required fields:

- `push_enabled`
- `order_updates`
- `deals_price_drops`
- `email_marketing`
- `sms_order_updates`

## Seller Onboarding Link

Needed endpoint/config:

- `GET /app-config`

Required field:

- `seller_onboarding_url`

## OTP / SMS

Current API returns `debug_code` outside production.

Production requirement:

- SMS provider must send OTP.
- `debug_code` must not be returned in production.

