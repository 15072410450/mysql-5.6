/*
   Portions Copyright (c) 2016-Present, Facebook, Inc.
   Portions Copyright (c) 2012, Monty Program Ab

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA */
#pragma once

#ifdef USE_PRAGMA_IMPLEMENTATION
#pragma implementation // gcc: Class implementation
#endif

/* C++ system header files */
#include <string>

/* RocksDB includes */
#include "rocksdb/compaction_filter.h"

/* MyRocks includes */
#include "./ha_rocksdb_proto.h"
#include "./rdb_datadic.h"

namespace myrocks {

class Rdb_compact_filter : public rocksdb::CompactionFilter {
public:
  Rdb_compact_filter(const Rdb_compact_filter &) = delete;
  Rdb_compact_filter &operator=(const Rdb_compact_filter &) = delete;

  explicit Rdb_compact_filter(uint32_t _cf_id) : m_cf_id(_cf_id) {}
  Rdb_compact_filter(std::vector<uint32> &&_droped_index_ids, uint32_t _cf_id) :
          m_cf_id(_cf_id), m_dropped_index_ids(_droped_index_ids) {}
  ~Rdb_compact_filter() {}

  // keys are passed in sorted order within the same sst.
  // V1 Filter is thread safe on our usage (creating from Factory).
  // Make sure to protect instance variables when switching to thread
  // unsafe in the future.
  virtual bool Filter(int level, const rocksdb::Slice &key,
                      const rocksdb::Slice &existing_value,
                      std::string *new_value,
                      bool *value_changed) const override {
    DBUG_ASSERT(key.size() >= sizeof(uint32));

    GL_INDEX_ID gl_index_id;
    gl_index_id.cf_id = m_cf_id;
    gl_index_id.index_id = rdb_netbuf_to_uint32((const uchar *)key.data());
    DBUG_ASSERT(gl_index_id.index_id >= 1);

    if (gl_index_id != m_prev_index) // processing new index id
    {
      if (m_num_deleted > 0) {
        m_num_deleted = 0;
      }
      m_should_delete = is_drop_index_ongoing(gl_index_id);
      m_prev_index = gl_index_id;
    }

    if (m_should_delete) {
      m_num_deleted++;
    }

    return m_should_delete;
  }

  virtual bool IgnoreSnapshots() const override { return true; }

  virtual const char *Name() const override { return "Rdb_compact_filter"; }

protected:
  // Column family for this compaction filter
  const uint32_t m_cf_id;

private:
  // Index id of the previous record
  mutable GL_INDEX_ID m_prev_index = {0, 0};
  // Number of rows deleted for the same index id
  mutable uint64 m_num_deleted = 0;
  // Current index id should be deleted or not (should be deleted if true)
  mutable bool m_should_delete = false;
  // Dropped indexes for compaction filter
  std::vector<uint32_t> m_dropped_index_ids;

  virtual inline bool is_drop_index_ongoing(
      const GL_INDEX_ID &gl_index_id) const {
    DBUG_ASSERT(gl_index_id.cf_id == m_cf_id);
    uint32_t index_id = gl_index_id.index_id;
    return std::binary_search(m_dropped_index_ids.begin(),
                              m_dropped_index_ids.end(), index_id);
  }
};

class Rdb_compact_filter_bitmap : public Rdb_compact_filter {
public:
  Rdb_compact_filter_bitmap(const Rdb_compact_filter_bitmap &) = delete;
  Rdb_compact_filter_bitmap &operator=(const Rdb_compact_filter_bitmap &) = delete;

  explicit Rdb_compact_filter_bitmap(uint32_t _cf_id) : Rdb_compact_filter(_cf_id) {}
  Rdb_compact_filter_bitmap(
      std::vector<bool> &&_dropped_index_ids_bitmap,
      uint32_t _cf_id,
      uint32_t _min_index) :
          Rdb_compact_filter(_cf_id),
          m_dropped_ids_bitmap(_dropped_index_ids_bitmap),
          m_min_index(_min_index) {}
  ~Rdb_compact_filter_bitmap() {}

  virtual const char *Name() const override { return "Rdb_compact_filter_bitmap"; }

private:
  std::vector<bool> m_dropped_ids_bitmap;
  uint32_t m_min_index;

  virtual inline bool is_drop_index_ongoing(
      const GL_INDEX_ID &gl_index_id) const override {
    DBUG_ASSERT(gl_index_id.cf_id == m_cf_id);

    if(gl_index_id.index_id < m_min_index) {
      return false;
    }
    uint32_t index_dist = gl_index_id.index_id - m_min_index;
    return index_dist < m_dropped_ids_bitmap.size() &&
           m_dropped_ids_bitmap[index_dist];
  }
};

class Rdb_compact_filter_factory : public rocksdb::CompactionFilterFactory {
public:
  Rdb_compact_filter_factory(const Rdb_compact_filter_factory &) = delete;
  Rdb_compact_filter_factory &
  operator=(const Rdb_compact_filter_factory &) = delete;
  Rdb_compact_filter_factory() {}

  ~Rdb_compact_filter_factory() {}

  const char *Name() const override { return "Rdb_compact_filter_factory"; }

  std::unique_ptr<rocksdb::CompactionFilter> CreateCompactionFilter(
      const rocksdb::CompactionFilter::Context &context) override {
    std::vector<uint32_t> dropped_index_ids;

    auto add_index_id = [](void *user_data, uint32_t index_id) {
      auto dropped_index_id_ptr = (std::vector<uint32_t> *)user_data;
      dropped_index_id_ptr->push_back(index_id);
    };

    rdb_get_dict_manager()->get_all_dropped_index_ongoing(
      context.column_family_id, &dropped_index_ids, add_index_id);

    if (dropped_index_ids.empty()) {
      return std::unique_ptr<rocksdb::CompactionFilter>(
          new Rdb_compact_filter(
                  std::move(dropped_index_ids), context.column_family_id));
    }
    if (dropped_index_ids.front() > dropped_index_ids.back()) {
      std::reverse(dropped_index_ids.begin(), dropped_index_ids.end());
    }
    uint32_t index_dist = dropped_index_ids.back() - dropped_index_ids.front() + 1;
    if (index_dist / (sizeof(uint32_t) * 4) > dropped_index_ids.size()) {
      return std::unique_ptr<rocksdb::CompactionFilter>(
          new Rdb_compact_filter(
                  std::move(dropped_index_ids), context.column_family_id));
    } else {
      std::vector<bool> dropped_index_ids_bitmap(index_dist, false);
      uint32_t min_index = *dropped_index_ids.begin();

      for (auto iter = dropped_index_ids.begin(); iter != dropped_index_ids.end(); ++iter) {
        dropped_index_ids_bitmap[*iter - min_index] = true;
      }
      return std::unique_ptr<rocksdb::CompactionFilter>(
          new Rdb_compact_filter_bitmap(
                  std::move(dropped_index_ids_bitmap), context.column_family_id, min_index));
    }
  }
};

} // namespace myrocks
