######################################################################
#
#  run_with_maveh.sh - A helper script that leverages the Maven machinery to
#  run java applications.
#
#  Set some shell variables and then source this script.
#
#  The following shell variables are required:
#
#   * DEPENDENCIES - an array of Maven dependencies in
#     groupId:artifactId:version (GAV) notation. The run_with_maven.sh script
#     will utilize maven functionality to ensure that these dependencies, as
#     well as any transtive dependencies, are present in the local maven cache,
#     ~/.m2/repository, downloading them from Maven Central if necessary.
#
#   * MAIN_CLASS - the class to be executed. It must have a `public static void
#     (String[] args)` method.
#
# The following shell variables may also be set:
#
#   * JAVA_OPTS - an array of any JVM options you want set
#
#   * JAVA_HOME - location of the JRE to use. The default behavior is to use whichever
#     java is on the PATH.
#
#   * MAIN_CLASS_ARGS - Arguments to provide to the main class. These are in
#     addition to the arguments provided to the calling script.
#
# You'll see below that the main class is called like this:
#
#    "$JAVACMD" "${JAVA_OPTS[@]}" \
#      -classpath "$(IFS=:; echo "${classpath_overall[*]}")" \
#      "${MAIN_CLASS}" "${MAIN_CLASS_ARGS[@]}" "$@"
#
# NOTE: The classpath calculation is expensive. It gets cached at
# `${XDG_CACHE_HOME:-$HOME/.cache}/<scriptname>.classpath`. If you add
# dependencies, or change their versions, it is necessary to remove that cache
# file to force the helper script to recalculate the classpath.  As a
# convenience, specifying the --clear-classpath option will remove this cache
# file for you.
#
######################################################################

# Look for options meant for this helper script.
# If found, set a flag and remove the option.
args=("$@") # Make a copy the arguments array
CLEAR_CLASSPATH=
indices_of_args_to_remove=()
declare -i i
i=-1
while :; do
  if [[ $# == 0 ]]; then
    break;
  fi
  i+=1
  case $1 in
    --clear-classpath)
      CLEAR_CLASSPATH=Y
      indices_of_args_to_remove+=($i)
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done
for i in "${indices_of_args_to_remove[@]}"; do
  unset -v 'args[i]'
done
set -- "${args[@]}"
unset args

# Ensure that the specified jar artificat is installed in the local maven cache
# and build the classpath array to contain the paths to the jar artifact and
# all its transitive dependency jars.
ensure_dependency_is_installed_in_the_maven_cache_and_build_classpath() {
  [[ $DEBUG ]] && echo "run_with_maven: Processing $1" >&2
  local GROUP_ID ARTIFACT_ID VERSION
  IFS=':' read -r GROUP_ID ARTIFACT_ID VERSION <<<$1
  local -r GROUP_ID ARTIFACT_ID VERSION

  local -r MAVEN_CACHE_DIR="$HOME/.m2/repository"
  local -r POM_DIR="$MAVEN_CACHE_DIR/$(echo "$GROUP_ID" | tr . /)/$ARTIFACT_ID/$VERSION"
  local -r POM_DIR
  local -r POM_PATH="$POM_DIR/$ARTIFACT_ID-$VERSION.pom"
  local -r JAR_PATH="${POM_PATH%.pom}.jar"
  [[ $DEBUG ]] && echo "run_with_maven: debug: POM_PATH:$POM_PATH" >&2

  # Ensure that the requested jar is in the maven cache
  mvn dependency:get -Dartifact=$GROUP_ID:$ARTIFACT_ID:$VERSION >&2
  [[ $? == 0 ]] || {
    echo "run_with_maven: error: maven couldn't get the artifact: $GROUP_ID:$ARTIFACT_ID:$VERSION" >&2
    exit 1
  }
  [[ -r "$JAR_PATH" ]] || {
    echo "run_with_maven: error: file not found: $JAR_PATH" >&2
    exit 1
  }

  # Initialize the classpath array with JAR_PATH
  [[ $DEBUG ]] && echo "run_with_maven: debug: adding to classpath: $JAR_PATH" >&2
  classpath=("$JAR_PATH")

  # Now the transitive dependencies
  local group_id artifact_id packaging version scope jar_path
  while IFS=: read group_id artifact_id packaging version scope; do
    [[ $DEBUG ]] && echo "run_with_maven: debug: $group_id:$artifact_id:$version" >&2
    if [[ $packaging != jar ]]; then
      [[ $DEBUG ]] && echo "run_with_maven: debug: continuing" >&2
      continue
    fi
    jar_path="$HOME/.m2/repository/$(echo "$group_id" | tr . /)/$artifact_id/$version/$artifact_id-$version.jar"
    [[ -r "$jar_path" ]] || {
      echo "run_with_maven: error: not found: $jar_path" >&2
      exit 1
    }
    [[ $DEBUG ]] && echo "run_with_maven: debug: adding to classpath: $jar_path" >&2
    classpath+=("$jar_path")
  done < <(
    mvn -f "$POM_PATH" dependency:list -DincludeScope=runtime \
      | awk '/^\[INFO\] The following files have been resolved:$/{flag=1; next}
             /^\[INFO\] *(?:none)? *|$/{flag=0}
             flag {print $2}'
  )
}

# Merge the classpath array into the classpath_overall array, avoiding duplicates
merge_classpath() {
  local IFS=:
  for p in "${classpath[@]}"; do
    case :"${classpath_overall[*]}": in
      *:$p:*)
        ;;
      *)
        classpath_overall+=("$p")
        ;;
    esac
  done
}

readonly CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/run_with_maven

mkdir -p "$CACHE_DIR" || {
  echo "run_with_maven: error: couldn't create cache dir $CACHE_DIR" >&2
  exit 1
}

readonly CACHE_FILE="$CACHE_DIR/${0##*/}.classpath"

[[ $DEBUG ]] && echo "run_with_maven: debug: CACHE_FILE: $CACHE_FILE"

declare -a classpath=() # classpath for one jar, including transitive dependencies
declare -a classpath_overall=() # All the classpaths merged together, with duplicates removed

if [[ $CLEAR_CLASSPATH ]] then
  [[ $DEBUG ]] && echo "The --clear_classpath option was present" >&2
  [[ $DEBUG ]] && echo "Will remove the cache file for classpath, if it exists" >&2
  rm -f "$CACHE_FILE"
fi

# Check if the classpath had been cached during a previous run
if [[ -r $CACHE_FILE ]]; then
  # Cache hit
  [[ $DEBUG ]] && echo "run_with_maven: debug: cache hit"
  IFS=':' read -r -a classpath_overall <"$CACHE_FILE"
else
  # Cache miss
  [[ $DEBUG ]] && echo "run_with_maven: debug: cache miss"
  for m in "${DEPENDENCIES[@]}"; do
    [[ $DEBUG ]] && echo "run_with_maven: debug: Processing jar: $m" >&2
    classpath=()
    ensure_dependency_is_installed_in_the_maven_cache_and_build_classpath "$m"
    [[ $? == 0 ]] || {
      echo "run_with_maven: error: there was an error processing maven coordinates $coordinates" >&2
      exit 1
    }
    # Merge classpath into classpath_overall
    merge_classpath
  done
  # Cache it
  [[ $DEBUG ]] && echo "run_with_maven: debug: caching the classpath for next run"
  echo "$(IFS=:; echo "${classpath_overall[*]}")" >"$CACHE_FILE"
fi

if [[ -z $JAVA_HOME ]] ; then
  JAVACMD=$(which java)
else
  JAVACMD=$JAVA_HOME/bin/java
fi
[[ -f $JAVACMD ]] || {
  echo "run_with_maven: error: java command not found: $JAVACMD" >&2
  exit 1
}
[[ $DEBUG ]] && echo "run_with_maven: debug: JAVACMD: $JAVACMD" >&2
[[ $DEBUG ]] && {
  echo "run_with_maven: debug: classpath components:" >&2
  printf '%s\n' "${classpath_overall[@]}" >&2
  echo -- end of classpath components -- >&2
}
[[ $DEBUG ]] && {
  echo "run_with_maven: debug: full command:" >&2
  echo "$JAVACMD" "${JAVA_OPTS[@]}" \
    -classpath "$(IFS=:; echo "${classpath_overall[*]}")" \
    "${MAIN_CLASS}" "${MAIN_CLASS_ARGS[@]}" "$@"
  echo -- end of full command -- >&2
}

# echo "$JAVACMD" "${JAVA_OPTS[@]}" \
#   -classpath "$(IFS=:; echo "${classpath_overall[*]}")" \
#   "${MAIN_CLASS}" "${MAIN_CLASS_ARGS[@]}" "$@"

"$JAVACMD" "${JAVA_OPTS[@]}" \
   -classpath "$(IFS=:; echo "${classpath_overall[*]}")" \
   "${MAIN_CLASS}" "${MAIN_CLASS_ARGS[@]}" "$@"
