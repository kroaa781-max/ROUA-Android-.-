-- Run this ONCE in Supabase SQL Editor after the initial tables have been created.
-- It adds safe order tracking by order code + phone number. It does not expose customer names/addresses.

grant select on public.admin_users to anon, authenticated;

alter table public.orders
  add column if not exists order_code text;

update public.orders
set order_code = 'ROU-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12))
where order_code is null;

alter table public.orders
  alter column order_code set default ('ROU-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12)));

alter table public.orders
  alter column order_code set not null;

create unique index if not exists orders_order_code_unique_idx
  on public.orders(order_code);

create or replace function public.get_order_status(p_order_code text, p_phone text)
returns table(order_code text, status text, total numeric, created_at timestamptz)
language sql
security definer
set search_path = public, pg_temp
as $$
  select o.order_code, o.status, o.total, o.created_at
  from public.orders o
  where o.order_code = p_order_code
    and o.phone = p_phone
  limit 1;
$$;

revoke all on function public.get_order_status(text, text) from public;
grant execute on function public.get_order_status(text, text) to anon, authenticated;

-- Validate product prices/availability and reserve stock inside the database transaction.
create or replace function public.validate_roua_order()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_item jsonb;
  v_product record;
  v_qty integer;
  v_total numeric := 0;
  v_product_id bigint;
begin
  if jsonb_typeof(new.items) <> 'array' or jsonb_array_length(new.items) = 0 then
    raise exception 'Order must contain at least one item';
  end if;

  for v_item in select value from jsonb_array_elements(new.items)
  loop
    begin
      v_product_id := (v_item->>'id')::bigint;
      v_qty := (v_item->>'qty')::integer;
    exception when others then
      raise exception 'Invalid product or quantity in order';
    end;

    if v_qty < 1 then
      raise exception 'Quantity must be positive';
    end if;

    select p.id, p.price, p.stock, p.sizes, p.active
      into v_product
      from public.products p
      where p.id = v_product_id
      for update;

    if not found or v_product.active is not true then
      raise exception 'A product is no longer available';
    end if;

    if not coalesce((v_item->>'selectedSize') = any(v_product.sizes), false) then
      raise exception 'Invalid size for a product';
    end if;

    if v_product.stock < v_qty then
      raise exception 'Not enough stock for a product';
    end if;

    update public.products set stock = stock - v_qty where id = v_product_id;
    v_total := v_total + (v_product.price * v_qty);
  end loop;

  if abs(new.total - v_total) > 0.01 then
    raise exception 'Order total does not match current product prices';
  end if;

  return new;
end;
$$;

drop trigger if exists validate_roua_order_before_insert on public.orders;
create trigger validate_roua_order_before_insert
before insert on public.orders
for each row execute function public.validate_roua_order();
