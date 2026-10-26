# ROUA Fashion — connected Android starter

A React Native + Expo women’s clothing storefront using Supabase for shared products, order storage, admin authentication, and order status updates.

## Included
- Beige/black ROUA storefront, product categories/search, size selection, favorites and cart
- Supabase-backed products and customer orders
- Admin login using the email/password account created in Supabase Authentication
- Admin access checked against `public.admin_users`
- Admin can add/delete products, see customer orders and update order status
- Customers can refresh the status of locally saved orders using order code + phone number
- Database trigger validates current prices, available sizes and stock before accepting an order, then decrements stock
- Cash on delivery only; no payment gateway or shipping fee calculation

## Required first setup
1. In Supabase SQL Editor, run the provided `supabase-setup-next.sql` once. It adds order codes, a privacy-limited status lookup function, and server-side price/stock validation.
2. Ensure your admin user was created in Authentication and its exact user ID is in `public.admin_users`.
3. The public project URL and publishable key are configured in `supabase.js`. Do not put any `service_role` or secret key in the app.
4. Install Node.js LTS on a computer, extract the folder, and run `npm install`.
5. Run `npx expo start`, install Expo Go on Android, and scan the QR code.
6. Open the Administration tab and sign in using the Supabase admin account. If the products table is empty, tap **رفع المنتجات التجريبية إلى قاعدة البيانات** or add your own products.

## Build an APK
1. Install EAS CLI: `npm install -g eas-cli`.
2. Run `eas login` in this folder.
3. Run `eas build -p android --profile preview`.

## Important limitations
- This is a connected starter project, not yet a fully audited production store. Test orders, inventory, login and RLS with separate customer/admin accounts before publishing.
- Product image input currently accepts an image URL, not uploading photos from the phone.
- Customer order status refresh is based on orders saved locally on that device; there is no customer account or cross-device order history yet.
- Delivery fee, return policy, privacy policy and customer support details must be configured before accepting real orders.
