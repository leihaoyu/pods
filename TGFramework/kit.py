import subprocess
import os


def replace_string_in_swift_interface(file_path, old_str, new_str):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # 替换字符串
    content = content.replace(old_str, new_str)

    # 写回文件
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

def process_files(folder_path, old_str, new_str):
    file_path = folder_path+'/project.pbxproj'
    replace_string_in_swift_interface(file_path, old_str, new_str)


def add_arm64(folder_path):
    old_str_to_replace = "GENERATE_INFOPLIST_FILE = YES;"
    new_str = "GENERATE_INFOPLIST_FILE = YES;EXCLUDED_ARCHS = arm64;"
    process_files(folder_path, old_str_to_replace, new_str)

def remove_arm64(folder_path):
        old_str_to_replace = "EXCLUDED_ARCHS = arm64;"
        new_str = ""
        process_files(folder_path, old_str_to_replace, new_str)

def check_and_execute(file_path,ensure):
    try:
        with open(file_path+'/project.pbxproj', 'r') as file:
            file_content = file.read()

            # 判断字符串是否在文件内容中
            if "EXCLUDED_ARCHS = arm64;" in file_content and not ensure:
                    remove_arm64(file_path)
            else:
                if ensure:
                    add_arm64(file_path)  # 如果不包含字符串，则执行函数 bb()
  
    except FileNotFoundError:
        print(f'文件 {file_path} 未找到')
    except Exception as e:
        print(f'发生错误: {e}')




k_name = "ComposePollUI"

workspace_path = f"/Users/thunder/Library/skt_tio/t-ios/TGFramework/{k_name}/{k_name}.xcodeproj"
scheme = k_name

command1 = f"xcodebuild archive -project {workspace_path} -scheme {scheme} -destination \"generic/platform=iOS Simulator\" -archivePath ./output/{scheme}-Sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"

command2 = f"xcodebuild archive -project {workspace_path} -scheme {scheme} -destination \"generic/platform=iOS\" -archivePath ./output/{scheme} SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"

command3 = f"xcodebuild -create-xcframework \
-framework ./output/{scheme}.xcarchive/Products/Library/Frameworks/{scheme}.framework \
-framework ./output/{scheme}-Sim.xcarchive/Products/Library/Frameworks/{scheme}.framework \
-output ./output/{scheme}.xcframework"



#
try:
    check_and_execute(workspace_path,True)
    result = subprocess.run(command1, shell=True, check=True)
    check_and_execute(workspace_path,False)
    result = subprocess.run(command2, shell=True, check=True)
    result = subprocess.run(command3, shell=True, check=True)
    
    print("Command executed successfully.")
except subprocess.CalledProcessError as e:
    print(f"Error executing command: {e}")

