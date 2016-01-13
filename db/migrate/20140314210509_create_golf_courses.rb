class CreateGolfCourses < ActiveRecord::Migration
  def change
    create_table :golf_courses do |t|
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end

    create_table :sub_courses do |t|
      t.string :course_name
      t.integer :golf_course_id

      t.timestamps
    end
  end
end
