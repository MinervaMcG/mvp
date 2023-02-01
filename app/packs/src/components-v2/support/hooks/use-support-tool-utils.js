import { useCallback, useState } from "react";
import { debounce } from "lodash";
import axios from "axios";

const FETCH_USERS_URL = "/support/search?username=";

export const useSupportToolUtils = () => {
  const [users, setUsers] = useState([]);
  const updateSearchData = useCallback(
    debounce(async e => {
      if (!e.target.value) return;
      const { data } = await axios.get(`${FETCH_USERS_URL}${e.target.value}`);
      setUsers(data);
    }, 250),
    [setUsers]
  );
  return {
    updateSearchData,
    users
  };
};
