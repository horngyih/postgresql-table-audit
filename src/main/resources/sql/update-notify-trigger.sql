create trigger product_update_notify
    after insert or update or delete
    on "Product"
    for each row
execute procedure update_notification();