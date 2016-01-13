Blogit::Post.class_eval do
  include Bootsy::Container
end

Blogit::PostsController.class_eval do
  helper Bootsy::ApplicationHelper

  def valid_params
    params.require(:post).permit(:title, :body, :blogger_type, :blogger_id, :bootsy_image_gallery_id)
  end
end
