class AlterSubscriptionColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscriptions, :commit_update
    rename_column :subscriptions, :cancellation_reason_comment, :cancellation_reason_comments
  end
end
