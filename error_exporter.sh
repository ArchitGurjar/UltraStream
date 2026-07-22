#!/data/data/com.termux/files/usr/bin/bash
cd /sdcard/ultrabuild/UltraStream || { echo "Project dir missing"; exit 1; }
REPORT="error_report.txt"
echo "===== ULTRASTREAM ERROR REPORT =====" > $REPORT
echo "Generated on: $(date)" >> $REPORT
echo "" >> $REPORT
echo "--- BUILD LOG ERRORS ---" >> $REPORT
for log in *.log app/build/*.log; do
    if [ -f "$log" ]; then
        echo "Processing: $log" >> $REPORT
        grep -n -i "error" "$log" >> $REPORT 2>/dev/null || true
        grep -n -i "unresolved" "$log" >> $REPORT 2>/dev/null || true
        grep -n -i "cannot find symbol" "$log" >> $REPORT 2>/dev/null || true
        grep -n -i "incompatible types" "$log" >> $REPORT 2>/dev/null || true
        grep -n -i "missing" "$log" >> $REPORT 2>/dev/null || true
    fi
done
echo "" >> $REPORT
echo "--- SOURCE CODE SCAN (Common Issues) ---" >> $REPORT
find . -name "*.kt" -o -name "*.java" | while read file; do
    if [ -f "$file" ]; then
        echo "File: $file" >> $REPORT
        grep -n -E "(Unresolved reference|Type mismatch|Val cannot be reassigned|Cannot infer type|Redundant|Unused|Missing|Expected|Required)" "$file" >> $REPORT 2>/dev/null || true
        grep -n -E "(var |val )" "$file" | grep -E "(not initialized|must be initialized)" >> $REPORT 2>/dev/null || true
        grep -n -E "(import|package)" "$file" | grep -E "(unresolved|not found)" >> $REPORT 2>/dev/null || true
    fi
done
echo "" >> $REPORT
echo "===== END REPORT =====" >> $REPORT
echo "✅ Report generated: $REPORT"
cat $REPORT
