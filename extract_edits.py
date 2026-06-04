#!/usr/bin/env python3
"""从对话日志中提取所有 edit_file 操作"""
import json
import re
import sys

def extract_edits_from_jsonl(filepath):
    """提取对话日志中的所有 edit_file 操作"""
    edits = []
    
    with open(filepath, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            try:
                data = json.loads(line)
                content = data.get('content', [])
                
                for item in content:
                    if item.get('type') == 'tool_use':
                        tool_name = item.get('name')
                        tool_input = item.get('input', {})
                        
                        if tool_name == 'edit_file':
                            file_path = tool_input.get('file_path', '')
                            if 'card_oh.dart' in file_path:
                                edits.append({
                                    'line': line_num,
                                    'old_text': tool_input.get('old_text', ''),
                                    'new_text': tool_input.get('new_text', ''),
                                    'file_path': file_path
                                })
                                
            except json.JSONDecodeError:
                continue
    
    return edits

def main():
    if len(sys.argv) < 2:
        print("Usage: python extract_edits.py <jsonl_file>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    edits = extract_edits_from_jsonl(filepath)
    
    print(f"Found {len(edits)} edit_file operations for card_oh.dart")
    
    for i, edit in enumerate(edits[:5]):  # 只显示前5个
        print(f"\n=== Edit {i+1} (line {edit['line']}) ===")
        print(f"Old text ({len(edit['old_text'])} chars):")
        print(repr(edit['old_text'][:200]))
        print(f"\nNew text ({len(edit['new_text'])} chars):")
        print(repr(edit['new_text'][:200]))
    
    # 保存完整结果
    output_file = filepath.replace('.jsonl', '_edits.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(edits, f, ensure_ascii=False, indent=2)
    print(f"\nSaved {len(edits)} edits to {output_file}")

if __name__ == '__main__':
    main()
