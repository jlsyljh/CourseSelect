class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list, :show_credits, :degree_course, :join_degree, :table,:edit]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  @@degree = []
  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 4)
    @course = @courses-current_user.courses
    tmp=[]
    @course.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
  end

def select
    days = "一二三四五六日"
    class_table = Array.new(22){Array.new(8){Array.new(12){}}}
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    $course_num=0
    $weeks=20
    $flag=0
    $conflict_course=""

    while $course_num < current_user.courses.length
      class_name = @current_user.courses[$course_num].name
      class_time = @current_user.courses[$course_num].course_time
      class_week = @current_user.courses[$course_num].course_week
      temp_raw = class_time[1,1]    
      # Recording when the class 
      $day=0
      $ar_ps=0 
      while $ar_ps < days.length
        if days[$ar_ps] == temp_raw
          $day=$ar_ps
        end
        $ar_ps+=1
      end
      $day+=1
      $i=0
      $m=0
      $n=0
      $t=0
      while $i < class_time.length do
        if class_time[$i] == '('
          $m = $i
        end
        if class_time[$i] == '-'
          $n = $i
        end
        if class_time == ')'
          $t = $i
        end
        $i+=1
      end

      # then we record when should we have class
      $start = class_time[$m+1..$n-1].to_i
      $end = class_time[$n+1..$t-2].to_i    

      #判断是否重选或者冲突
      class_week = class_week.delete("第")
      class_week = class_week.delete("周")
      class_week = class_week.split(",")

      $beg1=0
      $beg2=0
      $end1=0
      $beg2=0
      $db = 0
      if class_week.length > 1
        temp=class_week[0].split("-")
        $beg1=temp[0].to_i
        $end1=temp[1].to_i  
        temp=class_week[1].split("-")   
        $beg2=temp[0].to_i
        $end2=temp[1].to_i 
        $db=1
      else
        temp=class_week[0].split("-")
        $beg1=temp[0].to_i
        $end1=temp[1].to_i 
        $beg2=-1
        $end2=-1 
      end
      sign=Array.new(23) {0}
      $ks=0
      while $ks<sign.length 
        if $db == 1
          if ((($ks>=$beg1)and($ks<=$end1))or(($ks>=$beg2)and($ks<=$end2)))
            sign[$ks]=1
          end
        else
          if (($ks>=$beg1)and($ks<=$end1))
            sign[$ks]=1            
          end
        end
        $ks+=1
      end
=begin
      Rails.logger.info $day
      Rails.logger.info $start
      Rails.logger.info $end
      Rails.logger.info $beg1
      Rails.logger.info $end1
      Rails.logger.info $beg2
      Rails.logger.info $end2
      Rails.logger.info "Important"      
=end
      $weekth=1
      $weekday=1


      #记录课表
      while $weekth <= $weeks
        if (sign[$weekth]==1)
          #Rails.logger.info "$weekth"      
          #Rails.logger.info $weekth
          #周几的课
          $weekday=$day  
          $temp_start=$start  
          if $flag !=0
            break
          end 
          while $temp_start <= $end
            if $course_num == current_user.courses.length-1
              #Rails.logger.info "course_num"
              #Rails.logger.info $course_num    
              #Rails.logger.info $temp_start  
              temp = class_table[$weekth][$weekday][$temp_start]
              if temp == class_name
                #已选
                $flag=1
                Rails.logger.info "已选"    
                break
              elsif !temp.nil?
                #冲突其他课
                $flag=2
                $conflict_course=temp
                Rails.logger.info temp      
                Rails.logger.info class_name
                Rails.logger.info "冲突其他课"
                Rails.logger.info $weekth
                Rails.logger.info $weekday
                Rails.logger.info $temp_start
                Rails.logger.info class_name
                break
              else
                #可选课
                class_table[$weekth][$weekday][$temp_start] = class_name
                Rails.logger.info "$可选课xx"     
                Rails.logger.info class_table[$weekth][$weekday][$temp_start]
                Rails.logger.info $weekth
                Rails.logger.info $weekday
                Rails.logger.info $temp_start
              end
            else
              class_table[$weekth][$weekday][$temp_start] = class_name   
              Rails.logger.info "$可选课zzzzz"    
              Rails.logger.info class_table[$weekth][$weekday][$temp_start]
              Rails.logger.info $weekth
              Rails.logger.info $weekday
              Rails.logger.info $temp_start
            end
            $temp_start+=1
          end        
        end
        $weekth+=1
      end   
      $course_num+=1
    end

    $lg=0
    while $lg<current_user.courses.length
      Rails.logger.info current_user.courses[$lg].name
      $lg+=1
    end

    Rails.logger.info "flag"
    Rails.logger.info $flag    


    if $flag == 1 
      $flag=0    
      current_user.courses.delete(@course) 
      current_user.courses<<@course
      flash={:warning => "您已经选择该课程,选课失败"}     
      redirect_to courses_path, flash: flash    

    elsif $flag == 2
      $flag=0    
      flash={:warning => "选课失败，#{class_name}与#{$conflict_course}时间冲突！"}  
      current_user.courses.delete(@course) 
      redirect_to courses_path, flash: flash 
    else
      lim_num = @course.limit_num+0
      stu_num = @course.student_num+0
      if lim_num > stu_num
        #@course.guidline="qweqwe"
        #Grade.create(:user_id => current_user.id, :course_id => @course.id)
        flash={:suceess => "成功选择课程: #{@course.name}"}
        temp_stu_num = @course.student_num+1
        @course.update_attributes(student_num:temp_stu_num)
        redirect_to courses_path, flash: flash
      else
        flash={:warning => "选课失败，选课人数已满！"}
        current_user.courses.delete(@course) 
        redirect_to courses_path, flash: flash 
      end
    end

  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    temp_stu_num=@course.student_num-1
    if temp_stu_num < 0
      temp_stu_num=0
    end
    @course.update_attributes(student_num:temp_stu_num)
    redirect_to courses_path, flash: flash
  end

  def show_credits
    @course = current_user.courses
    @credits = 0.0
    @credits_public = 0.0
    @credits_professional = 0.0
    @course.each do |course|
      @credit_str = course.credit.slice 3,3
      @credits += @credit_str.to_f
      if course.course_type == "公共选修课"
        @credit_public_str = course.credit.slice 3,3
        @credits_public += @credit_public_str.to_f
      end
    end
    @@degree.each do |course|
      @credit_professional_str = course.credit.slice 3,3
      @credits_professional += @credit_professional_str.to_f
    end
  end

  def degree_course
    @course = current_user.courses - @@degree
    tmp = []
    @course.each do |course|
      if course.course_type != "公共选修课"
        tmp<<course
      end
    end
    @course = tmp
  end

  def join_degree
    @course = Course.find_by_id(params[:id])
    @@degree<<@course
    flash={:success => "成功设为学位课: #{@course.name}"}
    redirect_to degree_course_courses_path, flash: flash
  end

  def table
    @course = current_user.courses
    @Mon1 = current_user.courses-current_user.courses
    @Mon2 = current_user.courses-current_user.courses
    @Mon3 = current_user.courses-current_user.courses
    @Tue1 = current_user.courses-current_user.courses
    @Tue2 = current_user.courses-current_user.courses
    @Tue3 = current_user.courses-current_user.courses
    @Wed1 = current_user.courses-current_user.courses
    @Wed2 = current_user.courses-current_user.courses
    @Wed3 = current_user.courses-current_user.courses
    @Thur1 = current_user.courses-current_user.courses
    @Thur2 = current_user.courses-current_user.courses
    @Thur3 = current_user.courses-current_user.courses
    @Fri1 = current_user.courses-current_user.courses
    @Fri2 = current_user.courses-current_user.courses
    @Fri3 = current_user.courses-current_user.courses
    @Sat1 = current_user.courses-current_user.courses
    @Sat2 = current_user.courses-current_user.courses
    @Sat3 = current_user.courses-current_user.courses
    @Sun1 = current_user.courses-current_user.courses
    @Sun2 = current_user.courses-current_user.courses
    @Sun3 = current_user.courses-current_user.courses
    @course.each do |course|
      @course_str = course.course_time.slice 0,2
      @time_str = course.course_time.slice 3,1
      @time = @time_str.to_i
      if @course_str == "周一"
        if @time < 5
          @Mon1<<course
        end
        if @time > 4 and @time < 9
          @Mon2<<course
        end
        if @time > 8
          @Mon3<<course
        end
      end
      if @course_str == "周二"
        if @time < 5
          @Tue1<<course
        end
        if @time > 4 and @time < 9
          @Tue2<<course
        end
        if @time > 8
          @Tue3<<course
        end
      end
      if @course_str == "周三"
        if @time < 5
          @Wed1<<course
        end
        if @time > 4 and @time < 9
          @Wed2<<course
        end
        if @time > 8
          @Wed3<<course
        end
      end
      if @course_str == "周四"
        if @time < 5
          @Thur1<<course
        end
        if @time > 4 and @time < 9
          @Thur2<<course
        end
        if @time > 8
          @Thur3<<course
        end
      end
      if @course_str == "周五"
        if @time < 5
          @Fri1<<course
        end
        if @time > 4 and @time < 9
          @Fri2<<course
        end
        if @time > 8
          @Fri3<<course
        end
      end
      if @course_str == "周六"
        if @time < 5
          @Sat1<<course
        end
        if @time > 4 and @time < 9
          @Sat2<<course
        end
        if @time > 8
          @Sat3<<course
        end
      end
      if @course_str == "周日"
        if @time < 5
          @Sun1<<course
        end
        if @time > 4 and @time < 9
          @Sun2<<course
        end
        if @time > 8
          @Sun3<<course
        end
      end

    end
  end

  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 4) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 4) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      return false
      #redirect_to root_url, flash: {danger: '学生请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      #redirect_to root_url, flash: {danger: '老师请登陆'}
      return false
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week, :guidline)
  end


end
