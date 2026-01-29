import os
import re

# Directory to scan
target_dir = r"c:\Users\Exomia\algo\MyGasolineraFlutter\lib"

# Regex to find conflict blocks
# <<<<<<< HEAD
# (content we want to keep)
# =======
# (content we want to discard)
# >>>>>>> origin/main
conflict_pattern = re.compile(
    r"<<<<<<< HEAD\s*\n(.*?)\n=======\s*\n.*?\n>>>>>>> origin/main",
    re.DOTALL
)

count = 0

for root, dirs, files in os.walk(target_dir):
    for file in files:
        if file.endswith(".dart"):
            file_path = os.path.join(root, file)
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                if "<<<<<<< HEAD" in content:
                    print(f"Fixing conflicts in: {file}")
                    # Replace keeping the content in the first group (HEAD)
                    new_content = conflict_pattern.sub(r"\1", content)
                    
                    if new_content != content:
                        with open(file_path, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        count += 1
                    else:
                        print(f"Warning: Marker found but regex didn't match cleanly in {file}")

            except Exception as e:
                print(f"Error processing {file_path}: {e}")

print(f"Finished. Fixed {count} files.")
