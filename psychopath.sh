#!/bin/bash

echo -e "\e[31m
█ ▄▄    ▄▄▄▄▄ ▀▄    ▄ ▄█▄     ▄  █ ████▄ █ ▄▄  ██     ▄▄▄▄▀ ▄  █
█   █  █     ▀▄ █  █  █▀ ▀▄  █   █ █   █ █   █ █ █ ▀▀▀ █   █   █
█▀▀▀ ▄  ▀▀▀▀▄    ▀█   █   ▀  ██▀▀█ █   █ █▀▀▀  █▄▄█    █   ██▀▀█
█     ▀▄▄▄▄▀     █    █▄  ▄▀ █   █ ▀████ █     █  █   █    █   █
 █             ▄▀     ▀███▀     █         █       █  ▀        █
  ▀                            ▀           ▀     █           ▀
                                                ▀                \e[0m"

echo -e "\e[97mpsychoPath 1.0 by brsthegck\e[0m - path env variable manipulation tool\e\n"

#Logging/message functions
SUCCESS(){
echo -e "\e[32m[ + ]\e[0m $1"
}

ERROR(){
echo -e "\e[31m[ ! ]\e[0m $1"
}

QUESTION(){
echo -e "\e[33m[ ? ]\e[0m $1"
}

NUMBER(){
echo -e "\e[97m[$1]\e[0m $2"
}

IFS=':'; path_arr=($PATH); unset IFS;

MAINMENUINPUTREGEX='^[1-4]$'
LISTPATHINPUTREGEX='^\d+$'

INPUTCHECK(){
  if ! [[ $1 =~ $2 ]] ; then
    continue
    echo boom
  fi
}

#Edit/view path functionality
APPENDTORC(){
  echo "" >> ~/.bashrc
  echo "#psychoPath: $2 at $(date)" >> ~/.bashrc
  echo "export PATH='$1'" >> ~/.bashrc
  echo "" >> ~/.bashrc

  export PATH="$1"
  IFS=':'; path_arr=($PATH); unset IFS;
}

ADDNEWPATH(){
newpath=''
ensure_prompt=''
inputloop=true

while $inputloop; do
  QUESTION 'Enter the new path, leave blank to cancel:'
  read newpath

  if [[ $newpath = "" ]]; then
    ERROR 'Cancelled adding new path.'
    break
  fi

  QUESTION "Confirm the new path by typing Y\y: ${newpath}"
  read ensure_prompt

  case $ensure_prompt in
    'Y'|'y')
      default_idx=$1
      default_idx=$((default_idx + 1)) #was dest_idx
      dest_idx=-2 #was -1

      while true; do
        QUESTION "Enter the index you want to push path to\nleave blank for default ($default_idx), -1 to cancel:"
        read dest_idx

        case $dest_idx in
          -1)
              ERROR 'Cancelled adding new path.'
              inputloop=false
              break
              ;;
          ""|$default_idx)
              #append path directly to the end of bashrc and environment
              APPENDTORC "$PATH:${newpath}" "Added a new path at $((default_idx))"
              SUCCESS "Path added successfully."
              inputloop=false
              break
              ;;
          *)
              dest_idx=$((dest_idx - 1)) #actual arrays start from 0

              if [[ dest_idx -lt 1 || dest_idx -gt ${#path_arr[@]} ]]; then
                ERROR 'Invalid input: index out of bounds.'
                ERROR 'Cancelling adding new path.'
                inputloop=false
                break
              fi

              #shift the array and add path there
              new_path_arr=( "${path_arr[@]:0:${dest_idx}}" "${newpath}" "${path_arr[@]:$dest_idx}" )
              new_path_var=""

              for path in "${new_path_arr[@]}";do
                new_path_var=$new_path_var:$path
              done

              new_path_var=${new_path_var:1}

              #echo "$new_path_var"
              APPENDTORC "${new_path_var}"
              SUCCESS "Path added successfully."
              inputloop=false
              break
              ;;
        esac
      done
      ;;
    *)
      ERROR 'Cancelled adding new path.'
      inputloop=false
      break
      ;;
  esac
done
}

EDITPATH(){
    edit_idx=$1
    edit_idx=$((edit_idx - 1)) #actual arrays start from 0

    edit_op=''
    inputloop=true

    while $inputloop; do
      NUMBER ' - ' "Editing path $((edit_idx + 1)): ${path_arr[$edit_idx]}"
      QUESTION 'What do you want to do?'
      NUMBER '1' 'Edit path'
      NUMBER '2' 'Delete path'
      NUMBER '3' 'Cancel'
      read edit_op
      case $edit_op in
          1)
                QUESTION 'Enter the new path, leave blank to cancel:'

                newpath=''
                read newpath

                case $newpath in
                  '')
                      ERROR 'Cancelled path editing.'
                      inputloop=false
                      break
                      ;;
                  *)
                      ensure_prompt=""
                      QUESTION "Confirm the new path by typing Y\y: ${newpath}"
                      read ensure_prompt

                      case $ensure_prompt in
                        "y"|"Y")
                            #Edit the path
                            new_path_arr=( "${path_arr[@]:0:${edit_idx}}" "${newpath}" "${path_arr[@]:$((edit_idx + 1))}" )
                            new_path_var=""

                            for path in "${new_path_arr[@]}";do
                              new_path_var=$new_path_var:$path
                            done

                            new_path_var=${new_path_var:1}
                            #echo "$new_path_var"

                            APPENDTORC "$new_path_var" "Edited the path at $((edit_idx + 1))"
                            SUCCESS 'Path edited successfully.'
                            inputloop=false
                            #break
                            ;;
                        *)
                            ERROR "Cancelled path editing."
                            inputloop=false
                            #break
                            ;;
                      esac
                      ;;
                esac
            ;;
          2)
              delete_prompt=""
              QUESTION 'Confirm the deletion by typing Y\y:'
              read delete_prompt

              case $delete_prompt in
                  'y'|'Y')
                      new_path_arr=( "${path_arr[@]:0:${edit_idx}}" "${path_arr[@]:$((edit_idx + 1))}" )
                      new_path_var=""

                      for path in "${new_path_arr[@]}";do
                        new_path_var=$new_path_var:$path
                      done

                      new_path_var=${new_path_var:1}
                      #echo "$new_path_var"

                      APPENDTORC "$new_path_var" "Deleted the path at $((edit_idx + 1))"
                      SUCCESS 'Path deleted successfully.'
                      inputloop=false
                      ;;
                  *)
                      ERROR "Cancelled path deletion."
                      inputloop=false
                      break
                      ;;
              esac

              ;;
          3)
              edit_op=''
              break
              ;;
          *)
              ERROR 'Invalid input'
              ;;
      esac
    done
}

LISTPATH(){
lans=-2

while [[ lans -gt ${#path_arr[@]} || lans -lt -1 ]]; do
  for path_idx in ${!path_arr[@]}; do
    NUMBER $((path_idx+1)) "${path_arr[path_idx]}"
  done

  QUESTION 'Choose a path index to edit, enter 0 to add new path, -1 to go back:'
  read lans
  case $lans in
    -1)
      break
      ;;
    0)
      ADDNEWPATH ${#path_arr[@]}
      lans=-2
      ;;
    *)
      if [[ lans -gt ${#path_arr[@]} || lans -lt -1 ]]; then
        ERROR 'Invalid input: index out of bounds.'
        continue
      fi

      EDITPATH $lans
      lans=-2
      ;;
  esac
done
}

#Main menu functionality
MAINMENU="
`QUESTION 'Choose an option:'`\n
`NUMBER 1 'Edit/view paths from environment variable'`\n
`NUMBER 2 'Show action history'`\n
`NUMBER 3 'Exit'`\n
"
ans=""

ACTIONHISTORY(){
grep -w -i "^#psychoPath:" ~/.bashrc | sed -e "s/^#psychoPath://"
}

DISPLAYMAINMENU(){
while [[ ans -lt 1 || ans -gt 4 ]] ; do
  #INPUTCHECK $ans $MAINMENUINPUTREGEX

  echo -e $MAINMENU
  read ans

  case $ans in
    1)
      LISTPATH
      ans=''
      ;;
    2)
      ACTIONHISTORY
      ans=''
      ;;
    3)
      break
      ;;
    *)
      ERROR 'Invalid input.'
      ;;
  esac
done
}

DISPLAYMAINMENU
