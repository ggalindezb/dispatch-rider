module DispatchRider
  module ScheduledJob::Migration
    def create_scheduled_jobs_table
      create_table :scheduled_jobs do |t|
        t.datetime :scheduled_at
        t.text :destinations
        t.text :message
        t.string :claim_id
        t.datetime :claim_expires_at

        t.index :scheduled_at
      end
    end
  end
end
