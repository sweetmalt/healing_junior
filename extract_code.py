#!/usr/bin/env python3
"""从对话日志中提取代码内容"""
import json
import re
import sys

def extract_code_from_dialog():
    filepath = 'dialog/2026-06-04.jsonl'
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 查找包含关键代码模式的行
    patterns = [
        'currentCards',
        'selectedCardIndex', 
        'drawnCardSets',
        'fanDisplayCards',
        'flyStartPositions',
        'flyStartOffset',
        'CardohPhase.viewing',
        '_CardDisplayView',
    ]
    
    # 统计各模式出现次数
    print("Pattern occurrences:")
    for p in patterns:
        count = content.count(p)
        print(f"  {p}: {count}")
    
    # 查找大的 tool_result（可能包含完整代码）
    print("\nSearching for large tool_result entries...")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    large_results = []
    for line_num, line in enumerate(lines, 1):
        if len(line) > 50000:  # 大于50KB的条目
            large_results.append((line_num, len(line)))
    
    print(f"Found {len(large_results)} large entries (>50KB)")
    for ln, size in large_results:
        print(f"  Line {ln}: {size} bytes")
    
    # 尝试查找包含完整类定义的位置
    print("\nSearching for class definitions in tool_results...")
    
    # 查找 write_file 操作
    write_operations = []
    for line_num, line in enumerate(lines, 1):
        try:
            data = json.loads(line)
            for item in data.get('content', []):
                if item.get('type') == 'tool_use' and item.get('name') == 'write_file':
                    inp = item.get('input', {})
                    if 'card_oh.dart' in inp.get('file_path', ''):
                        code = inp.get('content', '')
                        if len(code) > 1000:  # 有实质性内容的写入
                            write_operations.append((line_num, len(code)))
        except:
            continue
    
    print(f"\nFound {len(write_operations)} write_file operations with substantial code")
    for ln, size in write_operations:
        print(f"  Line {ln}: {size} characters")
    
    # 提取所有 edit_file 操作
    print("\nExtracting all edit_file operations...")
    
    edits = []
    for line_num, line in enumerate(lines, 1):
        try:
            data = json.loads(line)
            for item in data.get('content', []):
                if item.get('type') == 'tool_use' and item.get('name') == 'edit_file':
                    inp = item.get('input', {})
                    if 'card_oh.dart' in inp.get('file_path', ''):
                        edits.append({
                            'line': line_num,
                            'old_text': inp.get('old_text', ''),
                            'new_text': inp.get('new_text', ''),
                        })
        except:
            continue
    
    print(f"Extracted {len(edits)} edit operations")
    
    # 分析 edit 操作
    print("\nAnalyzing edit patterns...")
    
    # 查找包含关键数据结构的 edit
    key_edits = []
    for e in edits:
        if any(k in e['new_text'] for k in patterns):
            key_edits.append(e)
    
    print(f"Found {len(key_edits)} edits containing key patterns")
    
    # 保存分析结果
    analysis = {
        'total_edits': len(edits),
        'pattern_counts': {p: content.count(p) for p in patterns},
        'large_entries': large_results,
        'write_operations': write_operations,
        'key_edits_sample': key_edits[:10] if key_edits else []
    }
    
    with open('dialog_analysis.json', 'w', encoding='utf-8') as f:
        json.dump(analysis, f, ensure_ascii=False, indent=2)
    
    print("\nSaved analysis to dialog_analysis.json")
    
    # 打印前几个关键 edit 的 new_text 内容
    print("\n" + "="*80)
    print("First 3 key edit operations (new_text content):")
    print("="*80)
    
    for i, e in enumerate(key_edits[:3]):
        print(f"\n--- Edit {i+1} at line {e['line']} ---")
        print(f"Old text ({len(e['old_text'])} chars): {repr(e['old_text'][:100])}")
        print(f"New text ({len(e['new_text'])} chars):")
        print(e['new_text'][:500])
        print("...")

if __name__ == '__main__':
    extract_code_from_dialog()
