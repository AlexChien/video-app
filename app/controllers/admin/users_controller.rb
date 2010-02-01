# 用户管理控制器。只有特定角色能使用本控制器
class Admin::UsersController < ApplicationController
  
  # acl9插件提供的访问控制列表DSL
  access_control do
    allow :admin
  end  
  
  before_filter :find_user, :only => [:show, :edit, :update, :destroy]

  def index
    if params[:state]
      @users = User.being(params[:state]).paginate(:page => params[:page], 
                                                     :order => 'created_at DESC', 
                                                     :per_page => 6)
    else
      @users = User.paginate(:page => params[:page], 
                               :order => 'created_at DESC', 
                               :per_page => 6)
    end
  end

  def show
    unless @user = User.find(params[:id])
      @user = @current_user
    end
    if params[:state]
      @videos = @user.videos.being(params[:state]).paginate(:page => params[:page], 
                                                     :order => 'created_at DESC', 
                                                     :per_page => 6)
    else
      @videos = @user.videos.paginate(:page => params[:page], 
                               :order => 'created_at DESC', 
                               :per_page => 6)
    end    
  end

  def edit
  end

  def update
    case  params[:commit]
    when "审核通过"
      begin 
        @user.audit! # 通过审核
        @user.queue! # 放入编码队列
        flash[:notice] = "审核已通过,已将视频放入编码队列"
      rescue StateMachine::InvalidTransition
        flash[:notice] = "已通过审核"
      end
    when "提交更新"
      @user.update_attributes(params[:user])
      flash[:notice] = "内容已更新"
    when "重新生成缩略图"
      @user.asset.reprocess!
      flash[:notice] = "缩略图已重新生成"
    when "中止编码" || "取消审核"
      @user.cancel!
      flash[:notice] = "已取消"
    when "重置视频"
      @user.resume!
      flash[:notice] = "已更改为待审核状态"
    when "手动编码"
      @user.fore_encode! # 将状态改为编码中才可使用paperclip的user_encoding processer
      begin
        begun_at = Time.now
        @user.started_encoding_at = begun_at
        @user.asset.reprocess! # 用paperclip processor处理视频编码
        @user.converted! # 编码结束
        ended_at = Time.now
        @user.encoded_at = ended_at
        @user.save!
        @user.encoding_time = ended_at - begun_at
        flash[:notice] = "视频已手动编码完成"
      rescue
        @user.failure! # 编码出错
        flash[:notice] = "编码时出错"
      end
    end
    redirect_to edit_admin_user_path(@user)
  end
  
  # 软删除视频
  def destroy
    begin
      @user.soft_delete!
      flash[:notice] = "视频已被删除"
    rescue StateMachine::InvalidTransition => e
      if e == "Cannot transition state via :soft_delete from :soft_deleted"
        flash[:notice] = "视频已被删除,无须再次删除"
      else
        flash[:error] = "出错，请联系管理员"
      end
    end
    redirect_to admin_users_path    
  end

private

  def find_user
    @user = User.find(params[:id])
  end

end
