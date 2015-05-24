#!/bin/bash

# bash-script-lib is copyright 2009-2011 Dejay Clayton, all rights reserved:
#     http://sourceforge.net/projects/bash-script-lib/
# bash-script-lib is licensed under the Apache License Version 2.0:
#     http://www.apache.org/licenses/LICENSE-2.0

compareArchiveFileAttributes() {
    local ARCHIVE_FILE_1="${1}"
    local ARCHIVE_FILE_2="${2}"

    [[ -f "${ARCHIVE_FILE_1}" && -f "${ARCHIVE_FILE_2}" ]] || return 2

    local SUM1=$( tar tvf "${ARCHIVE_FILE_1}" | sort | cksum )
    local SUM2=$( tar tvf "${ARCHIVE_FILE_2}" | sort | cksum )

    [[ "${SUM1}" == "${SUM2}" ]]
}

compareArchiveFileContents() {
    local ARCHIVE_FILE_1="${1}"
    local ARCHIVE_FILE_2="${2}"
    local IS_OPTIMISTIC=$( parseBoolean "${3:-false}" )

    [[ -f "${ARCHIVE_FILE_1}" && -f "${ARCHIVE_FILE_2}" ]] || return 2

    compareArchiveFileList "${ARCHIVE_FILE_1}" "${ARCHIVE_FILE_2}"
    [[ ${?} -eq 0 ]] || return 1

    # Remove paths with trailing slashes, because they are directory entries,
    # and cause erroneous tar errors to be displayed.  Also strip link
    # destinations, as they mess with the comparison logic.
    local FILE_ATTRIBUTE_DIFF_LIST=$(
        diff <( tar tvf "${ARCHIVE_FILE_1}" | sort ) \
             <( tar tvf "${ARCHIVE_FILE_2}" | sort ) \
        | grep '^<' | grep -v '/$' | sed 's/^\(< l.*\) ->.*$/\1/g' \
        | cut -d ' ' -f 4- | sed 's/^ \+//g' | cut -d ' ' -f 4- )

    [[ "${FILE_ATTRIBUTE_DIFF_LIST}" == '' && ${IS_OPTIMISTIC} -ne 0 ]] && {
        return 0
    }

    eval "$( macroArrayFromLines FILE_ATTRIBUTE_DIFF_LIST FILES )"

    local SUM1=$( tar xf "${ARCHIVE_FILE_1}" "${FILES[@]}" -O | cksum )
    local SUM2=$( tar xf "${ARCHIVE_FILE_2}" "${FILES[@]}" -O | cksum )

    [[ "${SUM1}" == "${SUM2}" ]]
}

compareArchiveFileList() {
    local ARCHIVE_FILE_1="${1}"
    local ARCHIVE_FILE_2="${2}"

    [[ -f "${ARCHIVE_FILE_1}" && -f "${ARCHIVE_FILE_2}" ]] || return 2

    local SUM1=$( tar tf "${ARCHIVE_FILE_1}" | sort | cksum )
    local SUM2=$( tar tf "${ARCHIVE_FILE_2}" | sort | cksum )

    [[ "${SUM1}" == "${SUM2}" ]]
}

compareGitBundles() {
    local GIT_BUNDLE_1="${1}"
    local GIT_BUNDLE_2="${2}"

    [[ -f "${GIT_BUNDLE_1}" && -f "${GIT_BUNDLE_2}" ]] || return 2

    cmp -s \
        <( git ls-remote "${GIT_BUNDLE_1}" ) \
        <( git ls-remote "${GIT_BUNDLE_2}" )
}

createArchive() {
    local ARCHIVE_FILE_NAME=$( normalizePath "${1}" )
    local ARCHIVE_ROOT_PATH=$( normalizePath "${2}" )
    local ARCHIVE_FILES_INCLUDED=$( normalizePathList "${3}" )
    local ARCHIVE_FILES_EXCLUDED=$( normalizePathList "${4}" )

    [[ "${ARCHIVE_FILES_INCLUDED}" != '' ]] || {
        notify 'ERROR: No files have been specified for backup'
        onError 1
    }

    tar -cz --ignore-failed-read --wildcards \
    --file="${ARCHIVE_FILE_NAME}" --directory="${ARCHIVE_ROOT_PATH}" \
    --files-from=<( echo -e "${ARCHIVE_FILES_INCLUDED}" ) \
    --exclude-from=<( echo -e "${ARCHIVE_FILES_EXCLUDED}" ) \
        2>&1 1>/dev/null \
    | grep -v 'tar: Removing leading\|Cannot stat: No such file or directory'

    return ${PIPESTATUS[0]}
}

backupGitRepository() {
    local BACKUP_FILE_NAME="${1}"
    local REPOSITORY_PATH="${2}"

    [[ -d "${REPOSITORY_PATH}" ]] || {
        notify "git repository '${REPOSITORY_PATH}' not found"
        return 1
    }

    if [[ -d "${REPOSITORY_PATH}/.git" ]]
    then
        notify "Backuping up local repository"
        REPOSITORY_PATH="${REPOSITORY_PATH}/.git"
    else
        notify "Backuping up remote repository"
    fi

    git --git-dir="${REPOSITORY_PATH}" bundle create \
        "${BACKUP_FILE_NAME}" --all
    onError ${?}
}

backupMySqlDatabase() {
    local BACKUP_FILE_NAME="${1}"
    local DATABASE_NAME="${2}"

    [[ "${DATABASE_NAME}" != '' ]] || DATABASE_NAME='--all-databases'

    mysqldump "${DATABASE_NAME}" \
        --add-drop-database --compact \
        --flush-logs --flush-privileges --opt \
        --no-autocommit --quote-names | bzip2 > "${BACKUP_FILE_NAME}"
    onError ${?}
}

backupPath() {
    local BACKUP_FILE_NAME=$( normalizePath "${1}" )
    local BACKUP_ROOT_PATH=$( normalizePath "${2}" )
    local ARCHIVE_FILES_EXCLUDED=$( normalizePathList "${3}" )

    [[ "${BACKUP_ROOT_PATH}" != '/' ]] || {
        notify 'System root directory cannot be backed up using function '\
"'backupPath'"

        onError 1
    }

    [[ "${BACKUP_ROOT_PATH}" != '' ]] || {
        notify 'No path was specified to be backed up'
        onError 1
    }

    tar -cz --ignore-failed-read --file="${BACKUP_FILE_NAME}" \
        --directory="${BACKUP_ROOT_PATH}" \
        --files-from=<( ls -A1 "${BACKUP_ROOT_PATH}" ) \
        --exclude-from=<( echo -e "${ARCHIVE_FILES_EXCLUDED}" ) \
        2>&1 1>/dev/null \
    | grep -v 'tar: Removing leading\|Cannot stat: No such file or directory'

    return ${PIPESTATUS[0]}
}

backupSvnRepository() {
    local BACKUP_FILE_NAME="${1}"
    local REPOSITORY_PATH="${2}"

    svnadmin dump --quiet "${REPOSITORY_PATH}" \
        | bzip2 > "${BACKUP_FILE_NAME}"
    onError ${?}
}

doesPathExistInArchive() {
    local ARCHIVE_FILE_NAME="${1}"
    local PATH_TO_FIND="${2}"

    [[ -f "${ARCHIVE_FILE_NAME}" ]] || return 2

    PATH_TO_FIND="${PATH_TO_FIND%%[/]}/"
    local MATCHES=$( tar tf "${ARCHIVE_FILE_NAME}" | grep "^${PATH_TO_FIND}" )

    [[ "${MATCHES}" != '' ]] && return 0
    return 1
}

findLatestArchiveFileWithPath() {
    local FILE_MATCH_REGEX="${1}"
    local PATH_TO_FIND="${2}"

    [[ "${PATH_TO_FIND}" == '' ]] || {
        PATH_TO_FIND=$( normalizePath "${PATH_TO_FIND}" )
        PATH_TO_FIND="${PATH_TO_FIND#[/]}/"
    }

    local MATCHING_FILE_LIST=$( findMatchingFiles "${1}" "${@:3}" )

    eval "$( macroArrayFromLines MATCHING_FILE_LIST MATCHING_FILES )"

    for file in "${MATCHING_FILES[@]}"
    do
        local FILES_IN_TAR=$( tar tf "${file}" | grep "^${PATH_TO_FIND}" )
        [[ "${FILES_IN_TAR}" != '' ]] || continue

        echo "${file}"
        return 0
    done

    return 1
}

listFilesInArchive() {
    local ARCHIVE_FILE_NAME=$( normalizePath "${1}" )

    [[ -f "${ARCHIVE_FILE_NAME}" ]] || return 2

    tar tvf "${ARCHIVE_FILE_NAME}" | grep -v '^d' | awk '{ print $6 }'
}

removeArchiveIfIdentical() {
    local FILE_TO_REMOVE="${1}"
    local FILE_TO_COMPARE="${2}"
    local COMPARE_ARCHIVE_CONTENTS=$( parseBoolean "${3:-true}" )

    if [[ ${COMPARE_ARCHIVE_CONTENTS} -ne 0 ]]
    then
        compareArchiveFileContents "${FILE_TO_REMOVE}" "${FILE_TO_COMPARE}"
    else
        compareArchiveFileAttributes "${FILE_TO_REMOVE}" "${FILE_TO_COMPARE}"
    fi

    case ${?} in
    0)
        rm "${FILE_TO_REMOVE}"
        return 0
        ;;

    1)
        return 1
        ;;

    *)
        return 2
        ;;
    esac
}

removeGitBundleIfIdentical() {
    local FILE_TO_REMOVE="${1}"
    local FILE_TO_COMPARE="${2}"

    compareGitBundles "${FILE_TO_REMOVE}" "${FILE_TO_COMPARE}"

    case ${?} in
    0)
        rm "${FILE_TO_REMOVE}"
        return 0
        ;;

    1)
        return 1
        ;;

    *)
        return 2
        ;;
    esac
}

restoreGitRepositoryFromBackupFile() {
    local GIT_REPOSITORY_BACKUP="${1}"
    local GIT_REPOSITORY_PATH="${2}"
    local GIT_SYSTEM_USER="${3}"
    local GIT_SYSTEM_GROUP="${4}"

    notify "Restoring git repository '${GIT_REPOSITORY_BACKUP}'"
    [[ -f "${GIT_REPOSITORY_BACKUP}" ]] || {
        notify "git repository '${GIT_REPOSITORY_BACKUP}' not found"
        return 1
    }

    notify "Making git repository directory '${GIT_REPOSITORY_PATH}/'"
    mkdir -p "${GIT_REPOSITORY_PATH}/"
    onError ${?}

    notify 'Changing git repository directory permissions'
    chown "${GIT_SYSTEM_USER}":"${GIT_SYSTEM_GROUP}" "${GIT_REPOSITORY_PATH}/"
    onError ${?}

    notify 'Restoring backup of git repository'
    sudo -u "${GIT_SYSTEM_USER}" git clone --bare \
        "${GIT_REPOSITORY_BACKUP}" "${GIT_REPOSITORY_PATH}"
    onError ${?}

    notify 'Finished installing git repository'
}

restoreSvnRepositoryFromBackupFile() {
    local SVN_REPOSITORY_BACKUP="${1}"
    local SVN_REPOSITORY_PATH="${2}"
    local SVN_SYSTEM_USER="${3}"
    local SVN_SYSTEM_GROUP="${4}"

    notify "Restoring Subversion repository '${SVN_REPOSITORY_BACKUP}'"
    [[ -f "${SVN_REPOSITORY_BACKUP}" ]] || {
        notify "Subversion repository '${SVN_REPOSITORY_BACKUP}' not found"
        return 1
    }

    notify 'Making Subversion repository directory'
    mkdir -p "${SVN_REPOSITORY_PATH}"
    onError ${?}

    notify 'Changing Subversion repository directory permissions'
    chown "${SVN_SYSTEM_USER}":"${SVN_SYSTEM_GROUP}" "${SVN_REPOSITORY_PATH}"
    onError ${?}

    notify 'Creating Subversion repository'
    sudo -u "${SVN_SYSTEM_USER}" svnadmin create "${SVN_REPOSITORY_PATH}"
    onError ${?}

    notify 'Restoring backup of Subversion repository'
    bzip2 -d -c "${SVN_REPOSITORY_BACKUP}" | \
        sudo -u "${SVN_SYSTEM_USER}" svnadmin load "${SVN_REPOSITORY_PATH}"
    onError ${?}

    notify 'Finished installing Subversion repository'
}

restorePathFromBackupFile() {
    local BACKUP_FILE_NAME="${1}"
    local RESTORE_PATH=$( normalizePath "${2}" )
    local PATH_USER="${3}"
    local PATH_GROUP="${4}"
    local BACKUP_CONTAINS_ABSOLUTE_PATHS=$( parseBoolean "${5:-false}" )

    [[ "${RESTORE_PATH}" != '/' ]] || {
        notify 'System root directory cannot be restored using function '\
"'restorePathFromBackup'"

        onError 1
    }

    [[ "${RESTORE_PATH}" != '' ]] || {
        notify 'No path was specified to be restored'
        onError 1
    }

    [[ "${BACKUP_FILE_NAME}" != '' ]] || {
        notify "No backup file was specified for path '${RESTORE_PATH}'"
        return 1
    }

    confirm "Restore path '${RESTORE_PATH}' from '${BACKUP_FILE_NAME}' "\
'? (y/n) '

    [[ ${?} -eq 0 ]] || return 1
 
    [[ ! -d "${RESTORE_PATH}" ]] || {
        confirm "Overwrite existing directory '${RESTORE_PATH}'? (y/n) "

        if [[ ${?} -eq 0 ]]
        then
            rm -rf "${RESTORE_PATH}"
            mkdir -p "${RESTORE_PATH}"
        else
            confirm "Restore backup '${BACKUP_FILE_NAME}' "\
"into existing directory '${RESTORE_PATH}'? (y/n) "

            [[ ${?} -eq 0 ]] || return 1
        fi
    }

    [[ -d "${RESTORE_PATH}" ]] || {
        notify "Creating directory '${RESTORE_PATH}'"

        local CREATED_DIR=1
        mkdir -p "${RESTORE_PATH}"

        onError ${?}
    }

    notify "Extracting path '${RESTORE_PATH}' from backup"

    if [[ ${BACKUP_CONTAINS_ABSOLUTE_PATHS} -ne 0 ]]
    then
        tar xzf "${BACKUP_FILE_NAME}" --directory='/' "${RESTORE_PATH:1}"
    else
        tar xzf "${BACKUP_FILE_NAME}" --directory="${RESTORE_PATH}"
    fi

    onError ${?}

    [[ "${PATH_USER}" != '' ]] && {
        notify "Restoring ownership of directory '${RESTORE_PATH}'"

        if [[ "${PATH_GROUP}" != '' ]]
        then
            chown "${PATH_USER}":"${PATH_GROUP}" "${RESTORE_PATH}"
            chown -R "${PATH_USER}":"${PATH_GROUP}" "${RESTORE_PATH}"/*
        else
            chown "${PATH_USER}" "${RESTORE_PATH}"
            chown -R "${PATH_USER}" "${RESTORE_PATH}"/*
        fi
    }

    onError ${?}
}

restoreUserFromBackupFile() {
    local BACKUP_FILE_NAME=$( normalizePath "${1}" )
    local USER_NAME=$( echo "${2}" | tr [:upper:] [:lower:] )
    local HOME_DIR=$( normalizePath "${3}" )

    # This function is designed to work with either: archive files that
    # contain absolute paths, and thus only the paths that are within the
    # user's home directory belong to the user, and the rest will be ignored;
    # or archive files that solely contain files that belong to the specified
    # user, with paths being interpreted as relative to the specified user's
    # home directory.  The following boolean, if true, indicates that the
    # archive contains files with absolute paths.
    local BACKUP_CONTAINS_ABSOLUTE_PATHS=$( parseBoolean "${4:-true}" )

    if [[ "${USER_NAME}" == 'root' ]]
    then
        local USER_IS_ROOT=1
    else
        local USER_IS_ROOT=0
    fi

    if doesUserExist "${USER_NAME}"
    then
        local HAS_USER=1
    else
        local HAS_USER=0
    fi

    if doesDirExist "${HOME_DIR}"
    then
        local HAS_HOME_DIR=1
    else
        local HAS_HOME_DIR=0
    fi

    if [[ "${BACKUP_FILE_NAME}" != '' ]]
    then
        local HAS_BACKUP_HOME_DIR=1
    else
        local HAS_BACKUP_HOME_DIR=0
    fi

    local DO_CMD_ADDUSER=0
    local DO_CMD_DELUSER=0
    local DO_CREATE_HOME_DIR=0
    local DO_RESTORE_HOME_DIR=0
    local DO_REMOVE_HOME_DIR=0

    if [[ ${HAS_USER} -ne 1 ]]
    then
        notify "User '${USER_NAME}' does not yet exist, and will be created"
        DO_CMD_ADDUSER=1
    else
        if [[ ${USER_IS_ROOT} -eq 1 ]]
        then
            notify "Privileged user 'root' already exists and will not be recreated"
        else
            notify "User '${USER_NAME}' already exists"
            confirm "Recreate user '${USER_NAME}' ? (y/n) "
            DO_CMD_ADDUSER=$(( ! ${?} ))
            DO_CMD_DELUSER=${DO_CMD_ADDUSER}
        fi
    fi

    DO_CREATE_HOME_DIR=${DO_CMD_ADDUSER}

    if [[ ${HAS_HOME_DIR} -ne 1 ]]
    then
        notify "Home directory '${HOME_DIR}' does not yet exist"
    else
        if [[ ${HAS_USER} -ne 1 ]]
        then
            notify "Orphaned home directory '${HOME_DIR}' currently exists"
        else
            notify "Home directory '${HOME_DIR}' currently exists"
        fi
    fi

    if [[ ${HAS_BACKUP_HOME_DIR} -ne 1 ]]
    then
        notify "No backup archive found for '${HOME_DIR}'"
    else
        confirm "Restore home directory from '${BACKUP_FILE_NAME}' ? (y/n) "
        if [[ ${?} -eq 0 ]]
        then
            DO_RESTORE_HOME_DIR=1
            DO_REMOVE_HOME_DIR=${HAS_HOME_DIR}
            DO_CREATE_HOME_DIR=0
        else
            DO_RESTORE_HOME_DIR=0
        fi
    fi

    [[ ${DO_CMD_ADDUSER} -eq 1 \
        && ${HAS_HOME_DIR} -eq 1 \
        && ${DO_RESTORE_HOME_DIR} -ne 1 ]] && \
    {
        confirm "Delete and recreate home directory '${HOME_DIR}' ? (y/n) "
        DO_REMOVE_HOME_DIR=$(( ! ${?} ))
        DO_CREATE_HOME_DIR=${DO_REMOVE_HOME_DIR}
    }

    if [[ ${DO_CMD_DELUSER} -eq 1 ]]
    then
        notify "Recreating user '${USER_NAME}'"
        if [[ ${DO_REMOVE_HOME_DIR} -eq 1 ]]
        then
            deluser "${USER_NAME}" --remove-home
            onError ${?}
        else
            deluser "${USER_NAME}"
            onError ${?}
        fi
    else
        [[ ${DO_REMOVE_HOME_DIR} -eq 0 ]] || {
            if [[ ${HAS_USER} -ne 1 ]]
            then
                notify "Removing orphaned home directory '${HOME_DIR}'"
            else
                notify "Removing existing home directory '${HOME_DIR}'"
            fi
            rm -rf "${HOME_DIR}"
            onError ${?}
        }
    fi

    [[ ${DO_CMD_ADDUSER} -eq 0 ]] || {
        [[ ${DO_CMD_DELUSER} -eq 0 ]] && notify "Adding user '${USER_NAME}'"

        if [[ ${DO_CREATE_HOME_DIR} -eq 1 ]]
        then
            adduser "${USER_NAME}" --disabled-password --gecos ''
            onError ${?}
        else
            adduser "${USER_NAME}" --disabled-password --gecos '' \
                --no-create-home 
            onError ${?}
        fi
    }

    [[ ${DO_RESTORE_HOME_DIR} -eq 0 ]] || {
        notify "Creating home directory '${HOME_DIR}'"
        mkdir -p "${HOME_DIR}"
        onError ${?}

        notify "Restoring '${HOME_DIR}' from '${BACKUP_FILE_NAME}'"

        if [[ ${BACKUP_CONTAINS_ABSOLUTE_PATHS} -ne 0 ]]
        then
            tar xzf "${BACKUP_FILE_NAME}" --directory=/ "${HOME_DIR:1}"
            onError ${?}
        else
            tar xzf "${BACKUP_FILE_NAME}" --directory="${HOME_DIR}"
            onError ${?}

            notify 'Restoring directory ownership'

            chown "${USER_NAME}":"${USER_NAME}" "${HOME_DIR}"
            chown -R "${USER_NAME}":"${USER_NAME}" "${HOME_DIR}"
            onError ${?}
        fi
    }
}
