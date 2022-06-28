import axios, { AxiosResponse } from 'axios';
import { EffectCallback, useEffect } from 'react';
import useSWR, { SWRResponse } from 'swr';

/* eslint-disable @typescript-eslint/no-explicit-any */
export function useSwrFetcher<T>(
    key: string[] | string,
): SWRResponse<AxiosResponse<T, any>, any> {
    return useSWR(
        key,
        async (url: string, params?: string) =>
            await axios.get<T>(url, { params }),
    );
}

/* eslint-disable react-hooks/exhaustive-deps */
/* see comments on https://stackoverflow.com/a/56767883
 * to see why the lint ignore is needed */
export const useMountEffect = (callback: EffectCallback): void =>
    useEffect(callback, []);
